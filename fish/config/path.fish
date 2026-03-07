# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# 環境変数
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx BAT_THEME TwoDark
set -gx GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/application_default_credentials.json

# PATH
fish_add_path $HOME/.local/bin

# Flutter
fish_add_path $HOME/dev/flutter/bin

# Yarn
fish_add_path $HOME/.yarn/bin
fish_add_path $HOME/.config/yarn/global/node_modules/.bin

# pnpm
set -gx PNPM_HOME $HOME/Library/pnpm
fish_add_path $PNPM_HOME

# Windsurf
fish_add_path $HOME/.codeium/windsurf/bin

# PostgreSQL (Homebrew)
fish_add_path /opt/homebrew/opt/postgresql@16/bin
