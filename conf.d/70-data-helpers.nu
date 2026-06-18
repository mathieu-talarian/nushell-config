# ~/.config/nushell/conf.d/70-data-helpers.nu
# Living documentation: Nushell's edge over bash is that everything is typed,
# tabular data you can filter/sort/group with pipelines — not text you grep.
# Run `nu-cheat` any time for a refresher. The two defs below are real, useful
# commands and also worked examples of the structured-data style.

# Print a categorized cheatsheet of structured-data idioms.
def nu-cheat [] {
    print "
FILES (ls returns a table: name type size modified)
  ls | where size > 10mb | sort-by modified         # big files, oldest first
  ls **/*.nu | where size > 1kb | select name size  # recursive glob + project
  bigfiles ~/Downloads --top 5                       # helper defined below

PROCESSES / SYSTEM (also tables/records)
  ps | where cpu > 5 | sort-by cpu --reverse         # busy processes
  sys mem                                            # memory as a record
  sys host | get uptime                              # pluck one field

ENVIRONMENT
  \$env.PATH                                          # this is a real list
  path-info | where exists == false                  # broken PATH entries

DATA FILES (open auto-parses by extension)
  open Cargo.toml | get package.version
  open data.csv | group-by category
  open data.json | where active | select id name

HTTP / APIs (responses become tables)
  http get https://api.github.com/repos/nushell/nushell | get stargazers_count

CONVERT / EXPLORE
  ls | to json                                       # also: to yaml, to csv
  open data.json | from json                         # parse a string
  ls | explore                                       # interactive table pager

DISCOVER (the docs are queryable too)
  help commands | where category == filters | select name usage
"
}

# Top files by size under a directory (recursive). Showcases glob + spread + sort.
def bigfiles [
    dir: path = "."          # directory to scan
    --top (-t): int = 20     # how many to return
] {
    ls ...(glob ($dir | path join "**" "*") --no-dir)
    | where type == file
    | sort-by size --reverse
    | first $top
    | select name size
}

# Your $env.PATH as a table, flagging entries that no longer exist on disk.
def path-info [] {
    $env.PATH
    | enumerate
    | each {|r| {idx: $r.index, path: $r.item, exists: ($r.item | path exists)} }
}
