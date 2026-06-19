# ~/.config/nushell/conf.d/20-completions.nu
# External completions via carapace (nushell.sh cookbook pattern).

if ((which carapace | is-empty) == false) {
    $env.CARAPACE_LENIENT = "1"

    let carapace_completer = {|spans|
        # TEMP DEBUG: log raw spans nushell passes in. Remove after diagnosis.
        $"(date now | format date '%H:%M:%S') raw=($spans | to json -r)\n" | save -a /tmp/nu-completer-debug.log
        # Workaround: completions don't work for aliases (nushell#8483).
        # Expand the FULL alias (not just its head) so multi-word aliases like
        # `gco = git checkout` complete with branch names, not git subcommands.
        let expanded_alias = (
            scope aliases
            | where name == $spans.0
            | get -o 0.expansion
        )

        let spans = if $expanded_alias != null {
            let expanded = (
                $expanded_alias
                | str replace -r '^\^' ''   # drop leading caret from `^cmd`
                | split row " "
                | where {|w| ($w | str trim) != "" }
            )

            $spans | skip 1 | prepend $expanded
        } else {
            $spans
        }

        try {
            ^carapace $spans.0 nushell ...$spans | from json
        } catch {
            null
        }
    }

    $env.config.completions.external = {
        enable: true
        max_results: 100
        completer: $carapace_completer
    }
}

if ((which command-not-found | is-empty) == false) {
    $env.config.hooks.command_not_found = {|cmd|
        try {
            (^command-not-found $cmd | complete).stdout
        } catch {
            $"Command not found: ($cmd)"
        }
    }
}
