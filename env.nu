# pnpm
$env.PNPM_HOME = "/Users/mathieumoullec/Library/pnpm"
$env.PATH = ($env.PATH | split row (char esep) | prepend ($env.PNPM_HOME | path join "bin") )
# pnpm end
