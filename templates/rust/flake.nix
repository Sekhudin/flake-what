{
  description = "FlakeWHAT! Rust-devShell flake.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = builtins.attrNames nixpkgs.legacyPackages;
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "[WHAT!] default rust-devShell";
            buildInputs = with pkgs; [
              cargo
              rustc
              rustfmt
              rust-analyzer
            ];
          };
        };
    };
}
