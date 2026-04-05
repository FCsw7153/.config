if status is-interactive
# Commands to run in interactive sessions can go here
end

# ---- alias ----
alias lg='lazygit'

# ---- python mirror ----
set -gx PYTHON_BUILD_MIRROR_URL "https://mirrors.tuna.tsinghua.edu.cn/python/"
set -gx PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM 1

# ---- local fish config ----
if test -r "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end

# ---- fzf ----
fzf --fish | source
set -gx FZF_DEFAULT_COMMAND 'find . -type f -not -path "*/.git/*" | sed "s#^\./##"'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'sed -n \"1,500p\" {}' --preview-window 'right,60%,border-left'"
set -gx FZF_CTRL_R_OPTS "--preview-window hidden"
