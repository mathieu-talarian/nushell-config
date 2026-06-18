# ~/.config/nushell/conf.d/21-native-completions.nu
# Nushell-native completions from nushell/nu_scripts (custom-completions/).
# These take priority over the carapace fallback configured in 20-completions.nu.
# To update: re-download the files in conf.d/completions/ from the nu_scripts repo.

use ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "git-completions.nu") *
use ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "npm-completions.nu") *
use ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "cargo-completions.nu") *
use ($nu.default-config-dir | path join "conf.d" | path join "completions" | path join "yarn-completions.nu") *
