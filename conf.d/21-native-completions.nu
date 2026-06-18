# ~/.config/nushell/conf.d/21-native-completions.nu
#
# Native nushell completions from nushell/nu_scripts live in conf.d/completions/.
# They are OPTIONAL overrides: anything not present here is handled by carapace
# (configured in 20-completions.nu), which covers ~660 commands and self-updates
# via `brew upgrade carapace`. A native `export extern` takes priority over
# carapace for that one command, so only add a file when nu_scripts is genuinely
# richer than carapace for some tool.
#
# You never hand-edit this file to add a completion. Instead:
#   completions-add <tool>     # download <tool> from nu_scripts + activate
#   completions-remove <tool>  # delete <tool> + regenerate loader
#   completions-update         # refresh all installed native completions
#   completions-reload         # rescan conf.d/completions/ after manual changes
#   reload                     # restart nu so the new externs are parsed
#
# `_loader.nu` is auto-generated (it `use`s every *.nu here) and sourced below at
# parse time. `_regen.nu` rebuilds it from the files actually on disk, so it
# self-heals. RECOVERY: if you ever manually delete a completion file and a new
# shell won't start, run this then reopen the shell:
#   nu ~/.config/nushell/conf.d/completions/_regen.nu

source ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "_loader.nu")

# Rescan conf.d/completions/ and regenerate _loader.nu (delegates to _regen.nu,
# the same logic usable standalone for recovery).
def completions-reload [] {
    let regen = ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "_regen.nu")
    nu $regen
    print "Run `reload` to activate."
}

# Download a completion from nushell/nu_scripts into conf.d/completions/.
# Example: `completions-add docker`  ->  custom-completions/docker/docker-completions.nu
def completions-add [
    tool: string   # tool name as it appears under custom-completions/ in nu_scripts
] {
    let dir = ($nu.default-config-dir | path join "conf.d" | path join "completions")
    let dest = ($dir | path join $"($tool)-completions.nu")
    let url = $"https://raw.githubusercontent.com/nushell/nu_scripts/main/custom-completions/($tool)/($tool)-completions.nu"

    print $"Fetching ($url) ..."
    try {
        http get $url | save -f $dest
    } catch {
        print $"Could not fetch ($tool). Browse available tools at:"
        print "  https://github.com/nushell/nu_scripts/tree/main/custom-completions"
        return
    }

    print $"Saved ($dest | path basename)."
    completions-reload
}

# Remove an installed native completion, then regenerate the loader.
def completions-remove [
    tool: string   # tool whose <tool>-completions.nu should be removed
] {
    let dir = ($nu.default-config-dir | path join "conf.d" | path join "completions")
    let target = ($dir | path join $"($tool)-completions.nu")

    if not ($target | path exists) {
        print $"No native completion installed for ($tool)."
        return
    }

    rm -f $target
    print $"Removed ($tool)-completions.nu."
    completions-reload
}

# Re-download every native completion already present, refreshing them from nu_scripts.
def completions-update [] {
    let dir = ($nu.default-config-dir | path join "conf.d" | path join "completions")
    let tools = (
        glob ($dir | path join "*-completions.nu")
        | each {|f| ($f | path basename | str replace "-completions.nu" "") }
    )

    if ($tools | is-empty) {
        print "No native completions installed; carapace is handling everything."
        return
    }

    $tools | each {|t| completions-add $t }
    print "All native completions refreshed. Run `reload` to activate."
}
