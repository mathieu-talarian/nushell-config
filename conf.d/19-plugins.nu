# ~/.config/nushell/conf.d/19-plugins.nu
# Nushell plugin management.
#
# Homebrew's `nushell` formula bundles the core plugin binaries (polars, gstat,
# formats, query, inc) prebuilt and version-locked — never `cargo install` them
# (especially on a rust nightly toolchain, where polars often won't compile).
# Register them once from the brew bin:
#   plugin add /opt/homebrew/bin/nu_plugin_gstat   # etc.
# Registered plugins persist in the registry and auto-load in new shells; no
# `plugin use` line is needed here.
#
# GOTCHA: `plugin add` stores the *resolved* Cellar path
# (e.g. /opt/homebrew/Cellar/nushell/0.113.1/bin/...), not the stable
# /opt/homebrew/bin symlink. A `brew upgrade nushell` deletes that Cellar dir,
# so every registered plugin goes dangling. Run `pluginsync` after upgrading.

# Re-register every currently-registered plugin against the current brew binary,
# repointing stale Cellar paths after a `brew upgrade nushell`.
def pluginsync [] {
    let bindir = (which nu | get 0.path | path dirname)

    let names = (plugin list | get name)
    if ($names | is-empty) {
        print "No plugins registered. Add one first, e.g.: plugin add nu_plugin_gstat"
        return
    }

    let results = (
        $names | each {|n|
            let bin = ($bindir | path join $"nu_plugin_($n)")
            if ($bin | path exists) {
                plugin add $bin
                {plugin: $n, status: "re-registered", path: $bin}
            } else {
                {plugin: $n, status: "MISSING — not in brew bin", path: $bin}
            }
        }
    )

    print "Done. Run `reload` (or open a new shell) to load the refreshed plugins."
    $results
}
