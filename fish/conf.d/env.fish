# ===== homebrew =====
set -l brew_paths \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew

for brew_bin in $brew_paths
    if test -x "$brew_bin"
        "$brew_bin" shellenv fish | source
        break
    end
end


# ===== conda =====
if status is-interactive
    if not functions -q conda
        set -l conda_paths \
            "$HOME/anaconda3/bin/conda" \
            "$HOME/miniconda3/bin/conda" \
            "/home/user/anaconda3/bin/conda" \
            "/home/user/miniconda3/bin/conda" \
            "/opt/conda/bin/conda" \
            "/data/ml/anaconda3/bin/conda" \
            "/data/ml/miniconda3/bin/conda" \
            "/root/anaconda3/bin/conda" \
            "/root/miniconda3/bin/conda"

        if set -q CONDA_EXE; and test -x "$CONDA_EXE"
            "$CONDA_EXE" shell.fish hook | source
        else
            for conda_bin in $conda_paths
                if test -x "$conda_bin"
                    "$conda_bin" shell.fish hook | source
                    break
                end
            end
        end
    end
end
