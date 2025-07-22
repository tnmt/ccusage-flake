{
  description = "ccusage with embedded Node.js runtime";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
        nodejs = pkgs.nodejs_20; # または必要なバージョン
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ccusage";
          version = "15.5.0";

          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/ccusage/-/ccusage-15.5.0.tgz";
            sha256 = "sha256-ce0QzFZV+5ZXCbKuCTaYiFcTsYWDsmYCnfVojVUzmbY=";
            stripRoot = true;
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            cd package
            mkdir -p $out/ccusage
            cp -r dist $out/ccusage/
            cp package.json $out/

            # 実行スクリプトを作成（Node.js のパスを固定）
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
