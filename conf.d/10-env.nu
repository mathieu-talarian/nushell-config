# ~/.config/nushell/conf.d/10-env.nu

$env.DOCKER_BUILDKIT = "1"
$env.COMPOSE_DOCKER_CLI_BUILD = "1"

$env.CGO_ENABLED = "1"
$env.CGO_CFLAGS = "-g -O2 -Wno-return-local-addr"

# macOS path_helper equivalent.
# zsh login shells get /etc/paths + /etc/paths.d/* via /etc/zprofile; Nushell
# doesn't run path_helper, so without this /usr/local/bin (Docker Desktop CLI),
# /opt/X11/bin, etc. are missing. Appended, so user dirs keep priority.
let etc_paths = (
    (["/etc/paths"] ++ (glob "/etc/paths.d/*"))
    | where {|f| $f | path exists }
    | each {|f| open $f | lines }
    | flatten
    | where {|l| ($l | str trim) != "" }
)

$env.PATH = ($env.PATH | append $etc_paths | uniq)

# Go
$env.GOPATH = ($env.HOME | path join "go")
path-prepend ($env.GOPATH | path join "bin")

# Homebrew / Linuxbrew
# Detect by file path, NOT `which brew`: as a login shell Nu starts with a bare
# PATH that doesn't include brew yet (chicken-and-egg).
let brew_prefix = (
    ["/opt/homebrew" "/usr/local" "/home/linuxbrew/.linuxbrew"]
    | where {|p| ($p | path join "bin" | path join "brew") | path exists }
    | get -o 0
)

if $brew_prefix != null {
    $env.HOMEBREW_PREFIX = $brew_prefix
    $env.HOMEBREW_CELLAR = ($brew_prefix | path join "Cellar")
    $env.HOMEBREW_REPOSITORY = $brew_prefix

    path-prepend ($brew_prefix | path join "bin")
    path-prepend ($brew_prefix | path join "sbin")

    $env.MANPATH = (env-prepend-string $env.MANPATH? ($brew_prefix | path join "share" | path join "man"))
    $env.INFOPATH = (env-prepend-string $env.INFOPATH? ($brew_prefix | path join "share" | path join "info"))
}

# Rust / Cargo
$env.CARGO_HOME = ($env.HOME | path join ".cargo")
path-prepend ($env.CARGO_HOME | path join "bin")

# Volta
$env.VOLTA_HOME = ($env.HOME | path join ".volta")
path-prepend ($env.VOLTA_HOME | path join "bin")

# JetBrains Tools
$env.JETBRAINS_TOOLS_HOME = ($env.HOME | path join ".jb")
path-prepend ($env.JETBRAINS_TOOLS_HOME | path join "bin")

# pyenv
$env.PYENV_ROOT = ($env.HOME | path join ".pyenv")

if (($env.PYENV_ROOT | path join "bin") | path exists) {
    path-prepend ($env.PYENV_ROOT | path join "bin")
}

# `pyenv root` just echoes $PYENV_ROOT, which we already set — skip the subprocess.
path-prepend ($env.PYENV_ROOT | path join "shims")

# Local binaries
path-prepend ($env.HOME | path join ".local" | path join "bin")

# JetBrains Toolbox
path-prepend (
    $env.HOME
    | path join ".local"
    | path join "share"
    | path join "JetBrains"
    | path join "Toolbox"
    | path join "scripts"
)

# Bun
$env.BUN_INSTALL = ($env.HOME | path join ".bun")
path-prepend ($env.BUN_INSTALL | path join "bin")

# rebar3
path-prepend ($env.HOME | path join ".cache" | path join "rebar3" | path join "bin")

# Google Cloud SDK (zsh did this via path.zsh.inc). gcloud/gsutil/bq
# completions come from carapace (20-completions.nu) once they're on PATH.
let gcloud_bin = ($env.HOME | path join "google-cloud-sdk" | path join "bin")
if ($gcloud_bin | path exists) { path-prepend $gcloud_bin }

# Editor / pager: prefer nvim + bat, fall back to what a bare system ships
# (minimal Fedora images have vi + more, not even less). Resolved LAST: on
# macOS, brew's bin dir (where nvim/bat live) is only on PATH after the
# Homebrew block above.
def first-available [candidates: list<string>, fallback: string] {
    $candidates | where {|c| which $c | is-not-empty } | get -o 0 | default $fallback
}
$env.EDITOR = (first-available [nvim vim vi] "vi")
$env.PAGER = (first-available [bat less more] "more")
$env.config.buffer_editor = $env.EDITOR
