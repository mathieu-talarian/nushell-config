# ~/.config/nushell/conf.d/17-atuin.nu
# Atuin: SQLite-backed shell history with fuzzy Ctrl-R search (and optional sync).
# atuin names both its keybindings "atuin"; nu >= 0.107 warns on duplicate
# names (upstream: atuinsh/atuin#2465). Rename the up-arrow one until fixed.
vendor-autoload atuin {
    ^atuin init nu
    | str replace -r 'name: atuin(\s+modifier: none)' 'name: atuin-up$1'
}
