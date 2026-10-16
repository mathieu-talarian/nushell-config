# ~/.config/nushell/conf.d/19-plugins.nu
# Nushell plugin management.
#
# Core plugins (polars, gstat, formats, query, inc) must match nu's exact
# version — never `cargo install` them (especially on a rust nightly
# toolchain, where polars often won't compile). Get them where nu came from:
#   macOS:  Homebrew's `nushell` bundles them prebuilt:
#             plugin add /opt/homebrew/bin/nu_plugin_gstat   # etc.
#   Fedora: the nushell RPM ships them in /usr/libexec/nushell/:
#             plugin add /usr/libexec/nushell/nu_plugin_gstat   # etc.
# Registered plugins persist in the registry and auto-load in new shells; no
# `plugin use` line is needed here.
#
# GOTCHA (Homebrew): `plugin add` stores the *resolved* Cellar path
# (e.g. /opt/homebrew/Cellar/nushell/0.113.1/bin/...), not the stable
# /opt/homebrew/bin symlink. A `brew upgrade nushell` deletes that Cellar dir,
# so every registered plugin goes dangling. Run `pluginsync` after upgrading.

# Re-register every registered plugin from the current nushell install
# (next to `nu` for brew, /usr/libexec/nushell for the Fedora RPM, else PATH),
# repointing stale paths and refreshing signatures after a nushell upgrade.
def pluginsync [] {
    let dirs = [(which nu | get 0.path | path dirname) "/usr/libexec/nushell"]

    let plugins = (plugin list | select name filename)
    if ($plugins | is-empty) {
        print "No plugins registered. Add one first, e.g.: plugin add nu_plugin_gstat"
        return
    }

    let results = (
        $plugins | each {|p|
            let file = $"nu_plugin_($p.name)"
            let bin = (
                $dirs | each {|d| $d | path join $file } | where {|f| $f | path exists }
                | append (which $file | get -o 0.path)
                | append (if ($p.filename | path exists) { $p.filename })
                | compact
                | get -o 0
            )
            if $bin != null {
                plugin add $bin
                {plugin: $p.name, status: "re-registered", path: $bin}
            } else {
                {plugin: $p.name, status: "MISSING — not found in nu's install dirs or on PATH", path: $p.filename}
            }
        }
    )

    print "Done. Run `reload` (or open a new shell) to load the refreshed plugins."
    $results
}
