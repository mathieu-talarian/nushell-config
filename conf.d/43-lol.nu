# ~/.config/nushell/conf.d/43-lol.nu

alias wtf = ^dmesg
alias onoz = ^cat /var/log/errors.log
alias rtfm = ^man
alias visible = ^echo
alias invisible = ^cat
alias moar = ^more
alias tldr = ^less
alias alwayz = ^tail -f
alias icanhas = ^mkdir
alias gimmeh = ^touch
alias donotwant = ^rm
alias dowant = ^cp
alias gtfo = ^mv
alias nowai = ^chmod
alias iz = ^eza
alias plz = pwd
alias ihasbucket = ^df -h
alias inur = ^locate
alias iminurbase = ^finger
alias btw = ^nice
alias obtw = ^nohup
alias nomz = ^ps aux
alias nomnom = ^killall
alias byes = exit
alias cya = ^reboot
alias kthxbai = ^halt
alias pwned = ^ssh
alias hackzor = ^git init
alias rulz = ^git push
alias bringz = ^git pull
alias chicken = ^git add
alias oanward = ^git commit -m
alias ooanward = ^git commit -am
alias letcat = ^git checkout
alias violenz = ^git rebase

def ":3" [...args: string] {
    ^echo ...$args
}

def --env hai [dir?: path] {
    if $dir == null {
        cd
    } else {
        cd $dir
    }
}

def yolo [] {
    let msg = (^curl -s https://whatthecommit.com/index.txt | str trim)
    ^git commit -m $msg
}
