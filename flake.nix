{
  description = "Personal dotfiles and CLI development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              self.formatter.${system}
              jq
              delta
            ];

            env = { };

            shellHook = ''
              echo "Nix CLI shell activated"
            '';
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
