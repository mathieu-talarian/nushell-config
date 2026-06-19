# ~/.config/nushell/conf.d/00-core.nu
# Core settings + helper commands used by the other conf.d files.

$env.config.show_banner = false
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "emacs"

$env.config.history = {
    file_format: sqlite
    max_size: 50_000
    sync_on_enter: true
    isolation: false
}

# Free up Ctrl-S/Ctrl-Q (no-op on failure, stderr captured)
try { ^stty stop undef | complete | ignore }

def --env path-prepend [p: path] {
    let p = ($p | path expand)

    $env.PATH = (
        $env.PATH
        | where {|x| ($x | path expand) != $p }
        | prepend $p
    )
}

# Write a tool's init output into Nu's vendor autoload dir. Those files load
# AFTER config.nu, so PATH from 10-env.nu is ready. No-op if the tool is absent.
def vendor-autoload [name: string, init: closure] {
    if (which $name | is-empty) { return }
    let dest = ($nu.data-dir | path join "vendor" "autoload" $"($name).nu")
    mkdir ($dest | path dirname)
    do $init | save -f $dest
}

def env-prepend-string [current: any, value: string] {
    let existing = ($current | default "")

    if ($existing | is-empty) {
        $value
    } else {
        [$value $existing] | str join (char esep)
    }
}

def nuconfig [] {
    run-external ($env.EDITOR? | default "nvim") $nu.config-path
}

# `source` is a parse-time keyword: sourcing config.nu from inside a def that
# config.nu itself loads would recurse at parse time. Replace the process instead.
def reload [] {
    exec nu
}
