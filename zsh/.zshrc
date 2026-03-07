# =========================================================
# .zshrc
# Purpose:
# - PATH / environment variables
# - prompt
# - language/runtime managers
# - plugin manager
# - shell completions
# =========================================================


# =========================================================
# 1) Base PATH
# Common executable paths used across the shell
# =========================================================
export PATH="/opt/homebrew/bin:/bin:/usr/bin:/usr/local/bin:$PATH"


# =========================================================
# 2) Google Cloud SDK / ADC
# gcloud executable path + application default credentials
# =========================================================
if [ -d "/opt/homebrew/share/google-cloud-sdk/bin" ]; then
  export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
elif [ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin" ]; then
  export PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
else
  echo "⚠ gcloud SDK がインストールされていません"
fi

# NOTE:
# PWD-based path changes depending on the current directory.
# Keep this only if your workflow intentionally depends on project root.
export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/.config/gcloud/application_default_credentials.json"


# =========================================================
# 3) Additional tool-specific PATH
# User/local tool paths
# =========================================================
# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Flutter
export PATH="$HOME/dev/flutter/bin:$PATH"

# Cursor Tunnel
export CURSOR_TUNNEL_PATH="/app/bin/cursor-tunnel"


# =========================================================
# 4) Prompt
# Use Starship as the shell prompt
# =========================================================
eval "$(starship init zsh)"

# Old Powerlevel10k settings (disabled)
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"


# =========================================================
# 5) Node.js / NVM
# Node Version Manager
# =========================================================
export NVM_DIR="$HOME/.nvm"
[[ -f "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
[[ -f "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
[[ -f "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"


# =========================================================
# 6) Ruby / rbenv
# =========================================================
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - zsh)"


# =========================================================
# 7) Python / pyenv
# =========================================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)" 2>/dev/null || true


# =========================================================
# 8) Python / Conda
# Keep this block if Conda is required in your environment
# =========================================================
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
[[ $? -eq 0 ]] && eval "$__conda_setup"
unset __conda_setup


# =========================================================
# 9) Zinit
# Plugin manager bootstrap + annexes
# =========================================================
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  git clone "https://github.com/zdharma-continuum/zinit.git" "$HOME/.local/share/zinit/zinit.git"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust


# =========================================================
# 10) Shell completions
# Docker Desktop completions + compinit
# =========================================================
fpath=(/Users/somomma/.docker/completions $fpath)
autoload -Uz compinit
compinit


# =========================================================
# 11) Aliases / custom shell helpers
# Add your personal shortcuts here
# =========================================================
# alias ls="eza"
# alias ll="eza -lah"
# alias lt="eza --tree"
# alias lg="eza -lah --git"
# alias g="lazygit"
# alias p="pet search"


# =========================================================
# 12) Local-only overrides
# Put machine-specific or temporary settings here
# =========================================================
# export SOME_LOCAL_VAR="value"