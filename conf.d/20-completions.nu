# ~/.config/nushell/conf.d/20-completions.nu
# External completions via carapace (nushell.sh cookbook pattern).

if ((which carapace | is-empty) == false) {
    $env.CARAPACE_LENIENT = "1"

    let carapace_completer = {|spans|
        # Workaround: completions don't work for aliases (nushell#8483)
        let expanded_alias = (
            scope aliases
            | where name == $spans.0
            | get -o 0.expansion
        )

        let spans = if $expanded_alias != null {
            let first = (
                $expanded_alias
                | split row " "
                | first
                | str replace --all "^" ""
            )

            $spans | skip 1 | prepend $first
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
