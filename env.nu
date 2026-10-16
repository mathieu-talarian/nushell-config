# pnpm
# pnpm's default home per OS: ~/Library/pnpm on macOS,
# $XDG_DATA_HOME/pnpm (~/.local/share/pnpm) on Linux.
$env.PNPM_HOME = if $nu.os-info.name == "macos" {
    $nu.home-dir | path join "Library" "pnpm"
} else {
    $env.XDG_DATA_HOME? | default ($nu.home-dir | path join ".local" "share") | path join "pnpm"
}
$env.PATH = ($env.PATH | split row (char esep) | prepend ($env.PNPM_HOME | path join "bin") )
# pnpm end
