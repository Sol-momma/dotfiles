# fnm (Node.js version manager)
fnm env --use-on-cd --shell fish | source

# zoxide (cd の強化版)
zoxide init fish | source

# direnv
direnv hook fish | source

# pyenv
if command -q pyenv
    set -gx PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - fish | source
end

# rbenv
if command -q rbenv
    rbenv init - fish | source
end

# conda
if test -f /opt/anaconda3/bin/conda
    eval /opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else if test -f /opt/anaconda3/etc/fish/conf.d/conda.fish
    source /opt/anaconda3/etc/fish/conf.d/conda.fish
end

# OrbStack
source ~/.orbstack/shell/init2.fish 2>/dev/null || true

# Google Cloud SDK
if test -d /opt/homebrew/share/google-cloud-sdk/bin
    fish_add_path /opt/homebrew/share/google-cloud-sdk/bin
else if test -d /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
    fish_add_path /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
end

# man を nvim で開く
if command -q nvim
    set -gx MANPAGER "nvim -c ASMANPAGER -"
end
