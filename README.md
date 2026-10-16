# nushell-config

My [Nushell](https://www.nushell.sh) config: modular `conf.d/` layout, carapace
completions, starship prompt, zoxide, atuin, direnv, fzf, git/docker/yarn aliases.
Works on macOS (Homebrew) and Fedora.

## Install on Fedora

```sh
curl -fsSL https://raw.githubusercontent.com/mathieu-talarian/nushell-config/main/install.sh | bash
```

This installs nushell (>= 0.116, from the official repo if yours is older) and the CLI
tools via dnf (starship from COPR, carapace from its fury repo). It then clones this
repo to `~/.config/nushell`, moving any existing one aside, registers the core plugins
and makes `nu` your login shell. Re-running it updates everything.

Options: `curl ... | bash -s -- --no-chsh` keeps your login shell, `--no-tools` skips the CLI tools.

## Install on macOS

```sh
brew install nushell starship carapace zoxide atuin eza bat fd fzf direnv neovim
git clone https://github.com/mathieu-talarian/nushell-config ~/.config/nushell
```

Machine-specific or secret settings go in `~/.config/nushell/local.nu`
(git-ignored, loaded last by `conf.d/99-local.nu`).
