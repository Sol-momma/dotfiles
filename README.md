# dotfiles

My development environment managed with Nix flakes.

## Setup

```bash
git clone git@github.com:Sol-momma/dotfiles.git
cd dotfiles

# Activate the Nix dev shell (requires direnv)
direnv allow

# Symlink Fish config
ln -sf "$PWD/fish" ~/.config/fish
```

## Nix

```bash
nix fmt          # Format all .nix files
nix develop      # Enter dev shell manually
nix flake show   # Inspect flake outputs
```

The dev shell provides: `nixfmt`, `jq`, `delta`.
