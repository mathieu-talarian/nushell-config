# ~/.config/nushell/conf.d/43-lol.nu
# Optional novelty aliases. Run `lol` to load them, `unlol` to unload them.

alias lol = overlay use ($nu.default-config-dir | path join "conf.d" | path join "overlays" | path join "lol.nu")
alias unlol = overlay hide lol
