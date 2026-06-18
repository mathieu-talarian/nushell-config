# ~/.config/nushell/conf.d/41-docker.nu
# docker compose shortcuts as aliases, so carapace can complete them
# (typing `dcup <tab>` expands to `docker compose up <tab>`).
#
# Target is the `docker compose` plugin (Compose v2, the current standard).
# If you land on a machine that only has the legacy standalone `docker-compose`,
# replace `^docker compose` with `^docker-compose` throughout this file.

alias dco = ^docker compose
alias dcb = ^docker compose build
alias dce = ^docker compose exec
alias dcps = ^docker compose ps
alias dcrestart = ^docker compose restart
alias dcrm = ^docker compose rm
alias dcr = ^docker compose run
alias dcstop = ^docker compose stop
alias dcup = ^docker compose up
alias dcupb = ^docker compose up --build
alias dcupd = ^docker compose up -d
alias dcupdb = ^docker compose up -d --build
alias dcdn = ^docker compose down
alias dcl = ^docker compose logs
alias dclf = ^docker compose logs -f
alias dclF = ^docker compose logs -f --tail 0
alias dcpull = ^docker compose pull
alias dcstart = ^docker compose start
alias dck = ^docker compose kill
