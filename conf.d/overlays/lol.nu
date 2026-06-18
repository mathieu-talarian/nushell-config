# ~/.config/nushell/conf.d/overlays/lol.nu

export alias wtf = ^dmesg
export alias onoz = ^cat /var/log/errors.log
export alias rtfm = ^man
export alias visible = ^echo
export alias invisible = ^cat
export alias moar = ^more
export alias tldr = ^less
export alias alwayz = ^tail -f
export alias icanhas = ^mkdir
export alias gimmeh = ^touch
export alias donotwant = ^rm
export alias dowant = ^cp
export alias gtfo = ^mv
export alias nowai = ^chmod
export alias iz = ^eza
export alias plz = pwd
export alias ihasbucket = ^df -h
export alias inur = ^locate
export alias iminurbase = ^finger
export alias btw = ^nice
export alias obtw = ^nohup
export alias nomz = ^ps aux
export alias nomnom = ^killall
export alias byes = exit
export alias cya = ^reboot
export alias kthxbai = ^halt
export alias pwned = ^ssh
export alias hackzor = ^git init
export alias rulz = ^git push
export alias bringz = ^git pull
export alias chicken = ^git add
export alias oanward = ^git commit -m
export alias ooanward = ^git commit -am
export alias letcat = ^git checkout
export alias violenz = ^git rebase

export def ":3" [...args: string] {
    ^echo ...$args
}

export def --env hai [dir?: path] {
    if $dir == null {
        cd
    } else {
        cd $dir
    }
}

export def yolo [] {
    let msg = (^curl -s https://whatthecommit.com/index.txt | str trim)
    ^git commit -m $msg
}
