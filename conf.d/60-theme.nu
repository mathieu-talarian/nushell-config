# ~/.config/nushell/conf.d/60-theme.nu
# Colors and table styling.

# Catppuccin Mocha for syntax highlighting + data rendering.
# To switch themes: replace conf.d/themes/catppuccin-mocha.nu with another
# file from https://github.com/nushell/nu_scripts/tree/main/themes/nu-themes
# and update the path below. (`source`, not `use`: the env changes from the
# theme's activate module only propagate to the shell when sourced.)
source ($nu.default-config-dir | path join "conf.d" | path join "themes" | path join "catppuccin-mocha.nu")

# Table rendering
$env.config.table.mode = "rounded"
$env.config.table.index_mode = "auto"

# ls colors via vivid (https://github.com/sharkdp/vivid), if installed
if ((which vivid | is-empty) == false) {
    $env.LS_COLORS = (^vivid generate catppuccin-mocha | str trim)
}
