# ===== conda =====
# 只初始化一次，并且只命中一个 conda
if not set -q CONDA_SHLVL
    set -l conda_bin

    if test -x /opt/homebrew/Caskroom/miniconda/base/bin/conda
        set conda_bin /opt/homebrew/Caskroom/miniconda/base/bin/conda
    else if test -x /opt/anaconda3/bin/conda
        set conda_bin /opt/anaconda3/bin/conda
    else if test -x /home/user/anaconda3/bin/conda
        set conda_bin /home/user/anaconda3/bin/conda
    else if test -x /home/user/miniconda3/bin/conda
        set conda_bin /home/user/miniconda3/bin/conda
    else if test -x /root/miniconda3/bin/conda
        set conda_bin /root/miniconda3/bin/conda
    else if test -x /root/anaconda3/bin/conda
        set conda_bin /root/anaconda3/bin/conda
    end

    if test -n "$conda_bin"
        $conda_bin shell.fish hook | source
    end
end

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
