# ~/.config/nushell/conf.d/30-aliases.nu

alias ls = ^eza --color=auto
alias l = ^eza
alias ll = ^eza -la
alias la = ^eza -lAh
alias lsa = ^eza -lah

alias grep = ^grep --color=auto
alias pip = ^pip3
alias cat = ^bat
alias tf = ^terraform
alias myip = ^ip-internal
alias sysinfo = ^inxi -Fxxxz
alias h = ^http

def vim [...args: string] {
    run-external ($env.EDITOR? | default "nvim") ...$args
}

def zshconfig [] {
    run-external ($env.EDITOR? | default "nvim") ($env.HOME | path join ".zshrc")
}

def checkup [] {
    ^sudo apt update
}

def up [] {
    ^sudo apt update
    if $env.LAST_EXIT_CODE == 0 {
        ^sudo apt upgrade -y
    }
}

def upnup [] {
    ^sudo apt update
    if $env.LAST_EXIT_CODE == 0 {
        ^sudo apt full-upgrade -y
    }
}

def cleanup [] {
    ^sudo apt autoremove -y
}

def psqlstart [] {
    ^sudo systemctl start postgresql.service
}

def npmnuke [] {
    print "Deleting **/node_modules/"
    glob "**/node_modules" | each {|d| rm --recursive --force $d }
}

# Do not hard-code your git-secret passphrase in config.
def gsr [...args: string] {
    let pass = if ($env.GIT_SECRET_PASSPHRASE? == null) {
        input --suppress-output "git-secret passphrase: "
    } else {
        $env.GIT_SECRET_PASSPHRASE
    }

    print ""
    ^git secret reveal -f -p $pass ...$args
}

def --env ".." [] { cd .. }
def --env "..." [] { cd ../.. }
def --env "...." [] { cd ../../.. }
def --env "....." [] { cd ../../../.. }
def --env "......" [] { cd ../../../../.. }

def md [...dirs: path] {
    ^mkdir -p ...$dirs
}

alias rd = ^rmdir

def als [pattern?: string] {
    let rows = (scope aliases | select name expansion)

    if $pattern == null {
        $rows
    } else {
        $rows | where {|r|
            ($r.name | str contains $pattern) or ($r.expansion | str contains $pattern)
        }
    }
}

def please [...cmd: string] {
    ^sudo ...$cmd
}

def --wrapped claude-awg [...args] {
  with-env { CLAUDE_CONFIG_DIR: ($nu.home-dir | path join ".claude_awg") } {
    ^claude ...$args
  }
}

# you-should-use: nag when you type a command that a shorter alias covers.
# Port of zsh-you-should-use. Matches the typed line against alias expansions;
# suggests the shortest-to-type alias whose expansion is a prefix of the line.
def _alias_hint [line: string] {
    let line = ($line | str trim)
    if ($line | is-empty) { return null }
    scope aliases
    | each {|a|
        let exp = ($a.expansion | str replace -r '^\^' '' | str trim)
        if (($line == $exp) or ($line | str starts-with $"($exp) ")) and (($a.name | str length) < ($exp | str length)) {
            {name: $a.name, len: ($exp | str length)}
        }
    }
    | compact
    | sort-by len --reverse
    | get -o 0.name
}

# Append (don't clobber) — atuin/etc. may already register pre_execution hooks.
$env.config.hooks.pre_execution = (
    $env.config.hooks.pre_execution? | default []
    | append {||
        let hint = (_alias_hint (commandline))
        if $hint != null {
            print $"(ansi yellow)💡 alias for that: (ansi yellow_bold)($hint)(ansi reset)"
        }
    }
)
