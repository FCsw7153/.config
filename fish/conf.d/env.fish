# ===== conda =====
if status is-interactive
    if not functions -q conda
        if set -q CONDA_EXE; and test -x "$CONDA_EXE"
            "$CONDA_EXE" shell.fish hook | source
        else if test -x "$HOME/anaconda3/bin/conda"
            "$HOME/anaconda3/bin/conda" shell.fish hook | source
        else if test -x "$HOME/miniconda3/bin/conda"
            "$HOME/miniconda3/bin/conda" shell.fish hook | source
        else if test -x /root/anaconda3/bin/conda
            /root/anaconda3/bin/conda shell.fish hook | source
        else if test -x /root/miniconda3/bin/conda
            /root/miniconda3/bin/conda shell.fish hook | source
        else if command -sq conda
            conda shell.fish hook | source
        end
    end
end

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
