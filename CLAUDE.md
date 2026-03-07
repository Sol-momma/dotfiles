# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with Nix flakes, targeting macOS (aarch64-darwin). Primary shell is Fish, with a legacy zsh config kept for reference.

## Key Commands

```bash
# Activate the dev shell (auto-activated via direnv)
direnv allow        # one-time setup
nix develop         # manual activation

# Format Nix files
nix fmt

# Inspect flake outputs
nix flake show
```

The dev shell (`flake.nix`) provides: `nixfmt`, `jq`, `delta`.

## Repository Structure

```
flake.nix               # Nix flake: devShell + formatter (nixfmt)
fish/
  config.fish           # Entrypoint: sources config/*.fish and theme
  config/
    path.fish           # PATH, env vars (Homebrew, Flutter, Yarn, pnpm, etc.)
    tools.fish          # Tool integrations: fnm, zoxide, direnv, pyenv, rbenv, conda, OrbStack, gcloud
    fzf.fish            # fzf options and key bindings
    abbr_ailiases.fish  # Fish abbreviations and aliases (git, docker, nix, AI tools)
  themes/kanagawa.fish  # Kanagawa color theme
  fish_plugins          # Fisher plugin list (pure-fish/pure)
zsh/.zshrc              # Legacy zsh config (reference only, not actively used)
starship/starship.toml  # Starship prompt config (Dracula palette, two-line format)
docs/FISH_MIGRATION.md  # Migration guide from zsh to fish
```

## Architecture

- **Environment activation**: `.envrc` uses `use flake`, so entering the directory auto-loads the Nix dev shell via direnv.
- **Fish config loading**: `config.fish` iterates over `fish/config/*.fish` and sources them all, then applies the Kanagawa theme. New config files dropped in `fish/config/` are auto-sourced.
- **Symlink management**: Fish config files are expected at `~/.config/fish/` — you need to symlink or copy `fish/` there manually (no stow or install script exists yet).
- **Formatter**: `nix fmt` runs `nixfmt` on all `.nix` files (configured as `formatter` output in `flake.nix`).

## Conventions

- Fish abbreviations (not aliases) are preferred — they expand inline so the full command is visible in history.
- The `abbr_ailiases.fish` file uses Fish 4.0+ `--command` (`-c`) flag for git sub-command abbreviations.
- Nix files should be formatted with `nixfmt` before committing.
