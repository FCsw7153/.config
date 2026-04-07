# ===== conda =====
# 只初始化一次，并且只命中一个 conda
if not set -q CONDA_SHLVL
    set -l conda_bin

    if test -x /opt/homebrew/Caskroom/miniconda/base/bin/conda
        set conda_bin /opt/homebrew/Caskroom/miniconda/base/bin/conda
    else if test -x /opt/anaconda3/bin/conda
        # ... 中间那些 else if 保持你的原样不变 ...
        set conda_bin /opt/anaconda3/bin/conda
    else if test -x /root/anaconda3/bin/conda
        set conda_bin /root/anaconda3/bin/conda
    end

    if test -n "$conda_bin"
        eval ($conda_bin shell.fish hook)
    end
end
