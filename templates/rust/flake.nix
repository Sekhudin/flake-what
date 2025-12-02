{
  description = "FlakeWHAT! Rust-devShell flake.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = builtins.attrNames nixpkgs.legacyPackages;
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
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
