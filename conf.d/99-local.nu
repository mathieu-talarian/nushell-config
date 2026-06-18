# ~/.config/nushell/conf.d/99-local.nu
# Private, machine-specific config (replaces ~/.localrc from zsh).
#
# `source` resolves at parse time, so `if (...) { source ... }` would fail
# when local.nu doesn't exist. The supported pattern is a const that resolves
# to either the path or null — `source null` is a no-op (nushell#14773).

const local_config = ($nu.default-config-dir | path join "local.nu")
const local_config_or_null = if ($local_config | path exists) { $local_config } else { null }

source $local_config_or_null
