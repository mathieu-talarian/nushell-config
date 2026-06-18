# ~/.config/nushell/conf.d/50-fzf.nu

$env.FD_OPTIONS = "--hidden --follow"

$env.FZF_DEFAULT_OPTS = "--prompt '⯈ ' --marker=+ --color=dark --layout=reverse --color=fg:250,fg+:15,hl:203,hl+:203 --color=info:100,pointer:15,marker:220,spinner:11,header:-1,gutter:-1,prompt:15"

$env.FZF_DEFAULT_COMMAND = $"fd --type f --type l ($env.FD_OPTIONS) || git ls-files --cached --others --exclude-standard"
$env.FZF_CTRL_T_COMMAND = $"fd ($env.FD_OPTIONS)"
$env.FZF_ALT_C_COMMAND = $"fd --type d ($env.FD_OPTIONS)"
$env.FZF_COMPLETION_OPTS = "-x"

def _fzf_compgen_path [base: string] {
    ^fd --hidden --follow . $base
}

def _fzf_compgen_dir [base: string] {
    ^fd --type d --hidden --follow . $base
}

if ((which fzf | is-empty) == false) and ((which fd | is-empty) == false) {
    $env.config.keybindings ++= [{
        name: fzf_change_dir
        modifier: alt
        keycode: char_c
        mode: [emacs vi_insert]
        event: {
            send: executehostcommand
            cmd: "let dir = (^fd --type d --hidden --follow . | ^fzf | str trim); if not ($dir | is-empty) { cd $dir }"
        }
    }]
}
