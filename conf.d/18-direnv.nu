# ~/.config/nushell/conf.d/18-direnv.nu
# direnv: load/unload .envrc environments on directory change.
# Official cookbook recipe (https://www.nushell.sh/cookbook/direnv.html, needs Nu >= 0.104).

use std/config *

# Initialize the PWD hook as an empty list if it doesn't exist
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

$env.config.hooks.env_change.PWD ++= [{||
    if (which direnv | is-empty) {
        # If direnv isn't installed, do nothing
        return
    }

    direnv export json | from json | default {} | load-env
    # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
    $env.PATH = do (env-conversions).path.from_string $env.PATH
}]
