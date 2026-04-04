if status is-interactive
# Commands to run in interactive sessions can go here
end

# ---- alias ----
alias lg='lazygit'

# ---- PATH / pyenv ---- 
set -gx PYENV_ROOT "$HOME/.pyenv"
if test (uname) = Darwin
    fish_add_path "$HOME/Library/Python/3.9/bin"
    fish_add_path "$PYENV_ROOT/bin"
else
    fish_add_path "$PYENV_ROOT/bin"
end

if command -q pyenv
    pyenv init - | source
end

# ---- conda ----
if test -x /home/user/anaconda3/bin/conda
    /home/user/anaconda3/bin/conda shell.fish hook | source
end

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
