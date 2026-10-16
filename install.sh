#!/usr/bin/env bash
# Bootstrap this Nushell config on Fedora (or any dnf-based Linux):
#
#   curl -fsSL https://raw.githubusercontent.com/mathieu-talarian/nushell-config/main/install.sh | bash
#
# Options (pass after `bash -s --`, e.g. `... | bash -s -- --no-chsh`):
#   --no-chsh    keep the current login shell (default: switch it to nu)
#   --no-tools   skip starship/carapace/CLI tools, only nushell + config
#
# Safe to re-run: installed packages are skipped, an existing clone is
# fast-forwarded, plugins are re-registered.

set -euo pipefail

REPO_URL="${NUSHELL_CONFIG_REPO:-https://github.com/mathieu-talarian/nushell-config.git}"
MIN_NU_VERSION="0.116.0"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nushell"

# CLI tools the config expects (aliases, hooks, keybindings).
DNF_TOOLS=(git atuin bat direnv eza fd-find fzf neovim zoxide)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m ✗\033[0m %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then SUDO=(); else SUDO=(sudo); fi
as_root() { "${SUDO[@]}" "$@"; }

version_ge() { # version_ge A B  ->  A >= B
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

add_repo_file() { # add_repo_file <name> <baseurl>
    local file="/etc/yum.repos.d/$1.repo"
    [ -f "$file" ] && return 0
    printf '[%s]\nname=%s\nbaseurl=%s\nenabled=1\ngpgcheck=0\n' "$1" "$1" "$2" \
        | as_root tee "$file" >/dev/null
}

dnf_install() { # install all at once; on failure retry one by one (warn, don't die)
    as_root dnf install -y "$@" >/dev/null 2>&1 && return 0
    local pkg
    for pkg in "$@"; do
        as_root dnf install -y "$pkg" >/dev/null 2>&1 || warn "could not install $pkg"
    done
}

check_platform() {
    [ "$(uname -s)" = "Linux" ] || die "This installer is for Linux (on macOS use Homebrew)."
    command -v dnf >/dev/null 2>&1 || die "dnf not found: this installer targets Fedora."
    if [ "${#SUDO[@]}" -gt 0 ]; then
        command -v sudo >/dev/null 2>&1 || die "sudo is required when not running as root."
        info "Some steps need sudo; you may be asked for your password."
        # sudo prompts on /dev/tty itself, so this works under `curl | bash`.
        sudo -v || die "sudo authentication failed."
    fi
}

install_nushell() {
    local current=""
    if command -v nu >/dev/null 2>&1; then
        current="$(nu --version 2>/dev/null || true)"
    fi
    if [ -n "$current" ] && version_ge "$current" "$MIN_NU_VERSION"; then
        ok "nushell $current already installed"
        return
    fi
    # Fedora's own `nushell` package is too old for this config; use the
    # official nushell repo (https://www.nushell.sh/book/installation.html).
    info "Installing nushell >= $MIN_NU_VERSION from the official nushell repo"
    add_repo_file gemfury-nushell https://yum.fury.io/nushell/
    as_root dnf install -q -y nushell >/dev/null
    as_root dnf upgrade -q -y nushell >/dev/null 2>&1 || true
    current="$(nu --version)"
    version_ge "$current" "$MIN_NU_VERSION" \
        || die "nushell $current is older than $MIN_NU_VERSION"
    ok "nushell $current"
}

install_tools() {
    info "Installing CLI tools: ${DNF_TOOLS[*]}"
    dnf_install "${DNF_TOOLS[@]}"

    if ! command -v starship >/dev/null 2>&1; then
        info "Installing starship (COPR atim/starship)"
        dnf_install dnf-plugins-core
        if as_root dnf copr enable -y atim/starship >/dev/null 2>&1; then
            dnf_install starship
        else
            warn "could not enable COPR atim/starship"
        fi
    fi

    if ! command -v carapace >/dev/null 2>&1; then
        info "Installing carapace (yum.fury.io/rsteube)"
        add_repo_file fury-carapace https://yum.fury.io/rsteube/
        dnf_install carapace-bin
    fi

    local t missing=()
    for t in starship carapace zoxide atuin eza bat fd fzf direnv nvim; do
        command -v "$t" >/dev/null 2>&1 || missing+=("$t")
    done
    if [ "${#missing[@]}" -eq 0 ]; then
        ok "all tools installed"
    else
        warn "missing (config still loads, related aliases won't work): ${missing[*]}"
    fi
}

install_config() {
    command -v git >/dev/null 2>&1 || dnf_install git
    if [ -d "$CONFIG_DIR/.git" ] \
        && git -C "$CONFIG_DIR" remote get-url origin 2>/dev/null | grep -q 'nushell-config'; then
        info "Updating existing config in $CONFIG_DIR"
        git -C "$CONFIG_DIR" pull --ff-only --quiet
    else
        if [ -e "$CONFIG_DIR" ]; then
            # The nushell RPM / first run creates a default config dir: keep it aside.
            local backup
            backup="$CONFIG_DIR.bak.$(date +%Y%m%d-%H%M%S)"
            mv "$CONFIG_DIR" "$backup"
            warn "moved existing $CONFIG_DIR to $backup"
        fi
        info "Cloning config into $CONFIG_DIR"
        mkdir -p "$(dirname "$CONFIG_DIR")"
        git clone --quiet "$REPO_URL" "$CONFIG_DIR"
    fi
    ok "config at $CONFIG_DIR ($(git -C "$CONFIG_DIR" rev-parse --short HEAD))"
}

register_plugins() {
    # Core plugins must match nu's version: take them from nu's own install
    # (/usr/libexec/nushell for the Fedora RPM, or next to the nu binary).
    local nu_dir plugins=()
    nu_dir="$(dirname "$(command -v nu)")"
    shopt -s nullglob
    plugins=(/usr/libexec/nushell/nu_plugin_* "$nu_dir"/nu_plugin_*)
    shopt -u nullglob
    if [ "${#plugins[@]}" -eq 0 ]; then
        warn "no nu_plugin_* binaries found next to nu or in /usr/libexec/nushell"
        return
    fi
    local p
    for p in "${plugins[@]}"; do
        [ -x "$p" ] || continue
        nu -c "plugin add '$p'" >/dev/null 2>&1 && ok "plugin $(basename "$p")" \
            || warn "could not register $(basename "$p")"
    done
}

validate_config() {
    info "Loading the config once to check it (also generates starship/zoxide/atuin init)"
    if nu --config "$CONFIG_DIR/config.nu" --env-config "$CONFIG_DIR/env.nu" -c 'exit 0'; then
        ok "config loads cleanly"
    else
        die "config failed to load: see the error above"
    fi
}

set_login_shell() {
    local nu_path current
    nu_path="$(command -v nu)"
    # Prefer the canonical /usr/bin path (on Fedora /usr/sbin aliases /usr/bin).
    if [ -x /usr/bin/nu ] && [ /usr/bin/nu -ef "$nu_path" ]; then nu_path=/usr/bin/nu; fi
    current="$(getent passwd "$(id -un)" | cut -d: -f7)"
    if [ "$current" = "$nu_path" ]; then
        ok "login shell is already $nu_path"
        return
    fi
    grep -qxF "$nu_path" /etc/shells || echo "$nu_path" | as_root tee -a /etc/shells >/dev/null
    # usermod (shadow-utils) is always present; chsh needs util-linux-user and
    # a PAM password prompt that doesn't work when the script is piped to bash.
    as_root usermod --shell "$nu_path" "$(id -un)"
    ok "login shell set to $nu_path (takes effect at next login)"
}

main() {
    local do_chsh=1 do_tools=1 arg
    for arg in "$@"; do
        case "$arg" in
            --no-chsh) do_chsh=0 ;;
            --no-tools) do_tools=0 ;;
            -h|--help) printf 'Usage: install.sh [--no-chsh] [--no-tools]\n'; return 0 ;;
            *) die "unknown option: $arg (try --help)" ;;
        esac
    done

    check_platform
    install_nushell
    if [ "$do_tools" -eq 1 ]; then install_tools; fi
    install_config
    register_plugins
    validate_config
    if [ "$do_chsh" -eq 1 ]; then
        set_login_shell
    else
        info "Skipped login shell change. Later: sudo usermod --shell $(command -v nu) $(id -un)"
    fi

    printf '\n'
    ok "Done. Open a new terminal (or run \`nu\`) to start your shell."
}

# Everything runs from here, so a partially downloaded script never executes.
main "$@"
