# dotfiles

My development environment managed with Nix flakes.

## Setup

```bash
git clone git@github.com:Sol-momma/dotfiles.git
cd dotfiles
direnv allow


nix flake show
nix eval .#formatter.aarch64-darwin --raw
nix run nixpkgs#nixfmt -- --version

nix fmt

