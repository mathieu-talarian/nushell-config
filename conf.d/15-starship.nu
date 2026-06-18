# ~/.config/nushell/conf.d/15-starship.nu
# Official Starship method: write starship.nu into Nu's vendor autoload dir.
# Vendor autoload files load AFTER config.nu, so PATH from 10-env.nu is ready.

if ((which starship | is-empty) == false) {
    let starship_autoload = (
        $nu.data-dir
        | path join "vendor"
        | path join "autoload"
        | path join "starship.nu"
    )

    mkdir ($starship_autoload | path dirname)
    ^starship init nu | save -f $starship_autoload
}
