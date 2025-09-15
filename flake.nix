{
  description = "ccusage with embedded Node.js runtime";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_22; # or desired version
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ccusage";
          version = "16.2.4";

          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/ccusage/-/ccusage-16.2.4.tgz";
            sha256 = "sha256-RJQx95J+CciX/FTewXWRShZMM+8TqydmetciyP0CBPI=";
            stripRoot = true;
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            mkdir -p $out/ccusage
            cp -r dist $out/ccusage/
            cp package.json $out/

            # Create wrapper script (pin Node.js path)
            mkdir -p $out/bin
            makeWrapper ${nodejs}/bin/node $out/bin/ccusage \
              --add-flags "$out/ccusage/dist/index.js"
          '';

          meta.mainProgram = "ccusage";
          meta.description = "ccusage CLI tool with embedded Node.js runtime";
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ccusage";
        };
      }
    );
}
