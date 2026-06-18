# Nushell Learning Targets

This file tracks the next things to learn and try in this Nushell setup.

## 1. Think In Structured Data

Learn Nu's table/list/record pipeline style before adding more aliases.

Try:

```nu
ls | where type == file | sort-by modified | last 10
open package.json | get scripts
http get https://api.github.com/repos/nushell/nushell | select full_name stargazers_count open_issues_count
```

Docs: https://www.nushell.sh/book/thinking_in_nu.html

## 2. Inspect Data With `explore`

Use `explore` as a structured-data pager instead of flattening everything to text.

Try:

```nu
ls | explore -i
$nu | explore
```

Docs: https://www.nushell.sh/book/explore.html

## 3. Use Focused Standard Library Imports

Import only the standard-library modules you need. Avoid `use std *` in startup
config because it has the highest load cost.

Try:

```nu
use std/log
use std/assert
use std/formats *
```

Docs: https://www.nushell.sh/book/standard_library.html

## 4. Register Core Plugins

Homebrew provides the core plugin binaries on this machine. Register the useful
ones, then restart Nu.

Try:

```nu
plugin add /opt/homebrew/bin/nu_plugin_gstat
plugin add /opt/homebrew/bin/nu_plugin_query
plugin add /opt/homebrew/bin/nu_plugin_formats
plugin add /opt/homebrew/bin/nu_plugin_inc
plugin list
```

Defer `nu_plugin_polars` until large CSV/DataFrame work becomes common.

Docs: https://www.nushell.sh/book/plugins.html

## 5. Keep Carapace As The Default Completer

Carapace covers broad external completions. Add native `nu_scripts` completions
only when a specific tool's completions feel better than carapace.

Try:

```nu
completions-add git
completions-add cargo
completions-add npm
```

Repository: https://github.com/nushell/nu_scripts

## 6. Learn Reedline Controls

Reedline powers editing, menus, history, keybindings, and hints. Useful entry
points:

```nu
keybindings list
keybindings listen
```

Docs: https://www.nushell.sh/book/line_editor.html

## 7. Use Optional Overlays For Extra Command Sets

Keep everyday startup lean. Load optional aliases only when wanted.

In this repo:

```nu
lol
unlol
```

Docs: https://www.nushell.sh/book/overlays.html

## 8. Keep `nupm` On The Watchlist

`nupm` is the Nushell package-manager experiment. It is interesting, but the
project currently labels itself experimental rather than production-ready.

Repository: https://github.com/nushell/nupm
