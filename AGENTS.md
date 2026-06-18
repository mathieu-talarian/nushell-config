Always call me Mr.Twinkle

you must use context7, serena, sequential thinking, graphify

# Nushell config

Personal Nushell config (`$nu.default-config-dir`). `config.nu` sources every
file in `conf.d/` in numeric order (`00-core` → `99-local`).

## Validate changes
- `nu -c 'source config.nu'` — parse the whole config; errors surface here.
- `reload` — exec a fresh `nu` to apply changes (from `conf.d/00-core.nu`).
- `nuconfig` — open config in `$EDITOR`.

## Gotcha: load list is explicit
`config.nu` is an explicit `source` list, NOT a glob. A new `conf.d/NN-x.nu`
won't load until you add a matching `source` line to `config.nu`.

## Completions
- External: **carapace** (`conf.d/20-completions.nu`), alias-aware — expands the
  full alias, so `gco<tab>` completes branch names. Update: `brew upgrade carapace`.
- Native nu_scripts files in `conf.d/completions/` auto-load via the generated
  `_loader.nu` (never hand-edit it). Manage with `completions-add <tool>`,
  `completions-remove <tool>`, `completions-update`, `completions-reload`.
  Recovery if a stale ref breaks startup: `nu conf.d/completions/_regen.nu`.

## Conventions
- Prefix external commands with `^` (`alias ls = ^eza`) to bypass builtins.
- Prefer `alias` over `def` for pure passthroughs — carapace completes aliases,
  not custom `def`s. Use `def` only for computed args / logic.
- `source`/`use` are parse-time: paths must be parse-time constants
  (`$nu.default-config-dir | path join ...`).
- History is SQLite; `history.sqlite3-wal`/`-shm` are transient (don't commit).
