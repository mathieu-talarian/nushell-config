# ~/.config/nushell/conf.d/41-docker.nu
# Note: flags passed to a custom command must be quoted ("-d", "--build"),
# otherwise Nu parses them as flags of __docker_compose itself.

def __docker_compose [...args: string] {
    if ((which docker-compose | is-empty) == false) {
        ^docker-compose ...$args
    } else {
        ^docker compose ...$args
    }
}

def dco [...args: string] { __docker_compose ...$args }
def dcb [...args: string] { __docker_compose build ...$args }
def dce [...args: string] { __docker_compose exec ...$args }
def dcps [...args: string] { __docker_compose ps ...$args }
def dcrestart [...args: string] { __docker_compose restart ...$args }
def dcrm [...args: string] { __docker_compose rm ...$args }
def dcr [...args: string] { __docker_compose run ...$args }
def dcstop [...args: string] { __docker_compose stop ...$args }
def dcup [...args: string] { __docker_compose up ...$args }
def dcupb [...args: string] { __docker_compose up "--build" ...$args }
def dcupd [...args: string] { __docker_compose up "-d" ...$args }
def dcupdb [...args: string] { __docker_compose up "-d" "--build" ...$args }
def dcdn [...args: string] { __docker_compose down ...$args }
def dcl [...args: string] { __docker_compose logs ...$args }
def dclf [...args: string] { __docker_compose logs "-f" ...$args }
def dclF [...args: string] { __docker_compose logs "-f" "--tail" "0" ...$args }
def dcpull [...args: string] { __docker_compose pull ...$args }
def dcstart [...args: string] { __docker_compose start ...$args }
def dck [...args: string] { __docker_compose kill ...$args }
