# ~/.config/nushell/conf.d/16-zoxide.nu
# Smarter cd: `z foo` jumps to your most-used dir matching "foo", `zi` is interactive.
# Same vendor-autoload pattern as starship (loads after config.nu, PATH ready).

if ((which zoxide | is-empty) == false) {
    let zoxide_autoload = (
        $nu.data-dir
        | path join "vendor"
        | path join "autoload"
        | path join "zoxide.nu"
    )

    mkdir ($zoxide_autoload | path dirname)
    ^zoxide init nushell | save -f $zoxide_autoload
}
