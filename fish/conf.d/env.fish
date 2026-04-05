if type -q conda
    conda shell.fish hook | source
else
    set -l conda_candidates \
        /home/user/anaconda3/bin/conda \
        /root/miniconda3/bin/conda \
        /root/anaconda3/bin/conda \
        /home/user/miniconda3/bin/conda

    for conda_bin in $conda_candidates
        if test -x $conda_bin
            $conda_bin shell.fish hook | source
            break
        end
    end
end

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
