{
  description = "FlakeWHAT! NodePG-devShell flake.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs.follows = "nixpkgs-stable";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    (flake-parts.lib.mkFlake { inherit inputs; }) {
      imports = [ inputs.process-compose-flake.flakeModule ];

      systems = builtins.attrNames nixpkgs.legacyPackages;

      perSystem =
        { pkgs, ... }:

        let
          toCamelCase =
            s:
            let
              seps = [
                "-"
                "_"
                "."
              ];
              split = builtins.foldl' (acc: sep: pkgs.lib.concatMap (pkgs.lib.splitString sep) acc) [ s ] seps;
              capitalize = str: (pkgs.lib.toUpper (builtins.substring 0 1 str)) + (builtins.substring 1 (-1) str);
            in
            builtins.concatStringsSep "" (
              pkgs.lib.imap0 (i: part: if i == 0 then pkgs.lib.toLower part else capitalize part) split
            );

          mkShells =
            pkgPrefix:
            let
              excluded = [ "nodejs_18" ];
              matches = builtins.filter (n: pkgs.lib.hasPrefix pkgPrefix n && !(builtins.elem n excluded)) (
                builtins.attrNames pkgs
              );
              mkShell =
                name:
                pkgs.mkShell {
                  name = "${toCamelCase name}-devShell";
                  description = "[WHAT!] ${name}-devShell";
                  buildInputs = [ pkgs.${name} ];
                };
            in
            builtins.listToAttrs (
              map (name: {
                name = toCamelCase name;
                value = mkShell name;
              }) matches
            );
        in
        {
          devShells = mkShells "nodejs_";

          process-compose.postgres = {
            imports = [ inputs.services-flake.processComposeModules.default ];

            services.postgres.me.enable = true;
            services.postgres.me.initialScript.before = ''
              CREATE USER nodepg WITH password 'postgres_nodepg';
            '';
            ######################################
            # optional
            ######################################
            # services.postgres.me.initialDatabases = [
            #   {
            #     name = "example_db";
            #     schemas = [ ./path_yuor_schema.sql ];
            #   }
            # ];
          };
        };
    };
}
