# ~/.config/nushell/conf.d/17-atuin.nu
# Atuin: SQLite-backed shell history with fuzzy Ctrl-R search (and optional sync).

if ((which atuin | is-empty) == false) {
    let atuin_autoload = (
        $nu.data-dir
        | path join "vendor"
        | path join "autoload"
        | path join "atuin.nu"
    )

    mkdir ($atuin_autoload | path dirname)
    ^atuin init nu | save -f $atuin_autoload
}
