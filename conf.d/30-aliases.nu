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
