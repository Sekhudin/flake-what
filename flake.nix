{
  description = "FlakeWHAT! Multi-devShell flake.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ nixpkgs, flake-parts, ... }:
    (flake-parts.lib.mkFlake { inherit inputs; }) {
      systems = builtins.attrNames nixpkgs.legacyPackages;

      perSystem =
        { pkgs, system, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "[WHAT!] default devShell.";
            buildInputs = with pkgs; [
            ];
          };
        };

      flake = {
        templates = rec {
          rust = {
            path = ./templates/rust;
            description = ''
              [WHAT!] - A devShell template for Rust.
            '';
          };
        };
      };
    };
}
