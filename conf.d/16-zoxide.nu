# ~/.config/nushell/conf.d/16-zoxide.nu
# Smarter cd: `z foo` jumps to your most-used dir matching "foo", `zi` is interactive.
vendor-autoload zoxide { ^zoxide init nushell }
