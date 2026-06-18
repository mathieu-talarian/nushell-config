# ~/.config/nushell/conf.d/40-git.nu
# Nu equivalent of OMZP::git.

def git_current_branch [] {
    let symbolic = (^git symbolic-ref --quiet HEAD | complete)

    if $symbolic.exit_code == 0 {
        $symbolic.stdout | str trim | str replace "refs/heads/" ""
    } else {
        let rev = (^git rev-parse --short HEAD | complete)

        if $rev.exit_code == 0 {
            $rev.stdout | str trim
        } else {
            ""
        }
    }
}

def git_main_branch [] {
    for branch in [main trunk mainline default stable master] {
        for prefix in [refs/heads refs/remotes/origin refs/remotes/upstream] {
            let result = (^git show-ref -q --verify $"($prefix)/($branch)" | complete)

            if $result.exit_code == 0 {
                return $branch
            }
        }
    }

    "master"
}

def git_develop_branch [] {
    for branch in [dev devel develop development] {
        let result = (^git show-ref -q --verify $"refs/heads/($branch)" | complete)

        if $result.exit_code == 0 {
            return $branch
        }
    }

    "develop"
}

alias g = ^git
alias ga = ^git add
alias gaa = ^git add --all
alias gst = ^git status
alias gss = ^git status --short
alias gsb = ^git status --short --branch
alias gd = ^git diff
alias gds = ^git diff --staged
alias gl = ^git pull
alias gp = ^git push
alias gf = ^git fetch
alias gfa = ^git fetch --all --tags --prune --jobs=10
alias gco = ^git checkout
alias gcl = ^git clone
alias gcb = ^git checkout -b
alias gsw = ^git switch
alias gswc = ^git switch --create
alias gcmsg = ^git commit --message
alias gc = ^git commit --verbose
alias gca = ^git commit --verbose --all
alias gcam = ^git commit --all --message
alias grb = ^git rebase
alias grba = ^git rebase --abort
alias grbc = ^git rebase --continue
alias grbi = ^git rebase --interactive
alias grh = ^git reset
alias grhh = ^git reset --hard
alias grs = ^git restore
alias grst = ^git restore --staged
alias gsta = ^git stash push
alias gstp = ^git stash pop
alias gstl = ^git stash list
alias gstc = ^git stash clear
alias glog = ^git log --oneline --decorate --graph
alias gloga = ^git log --oneline --decorate --graph --all

def gcm [] {
    ^git checkout (git_main_branch)
}

def gcd [] {
    ^git checkout dev
}

def ggp [] {
    ^git push origin (git_current_branch)
}

def ggl [] {
    ^git pull origin (git_current_branch)
}

def ggpnp [] {
    ggl
    if $env.LAST_EXIT_CODE == 0 {
        ggp
    }
}

def gpsup [] {
    ^git push --set-upstream origin (git_current_branch)
}

def ggsup [] {
    ^git branch --set-upstream-to=$"origin/(git_current_branch)"
}

def gwip [] {
    ^git add -A

    let deleted = (^git ls-files --deleted | lines)

    if (($deleted | length) > 0) {
        ^git rm ...$deleted
    }

    ^git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

def gunwip [] {
    let subject = (
        ^git rev-list --max-count=1 "--format=%s" HEAD
        | lines
        | skip 1
        | str join ""
    )

    if ($subject | str contains "--wip--") {
        ^git reset HEAD~1
    }
}
