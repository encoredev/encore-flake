{
  description = "nix flake that wraps the released encore binaries";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      alphaRelease = import ./release-alpha.nix;
      betaRelease = import ./release-beta.nix;
      nightlyRelease = import ./release-nightly.nix;

      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      # Lets consumers build encore with their own nixpkgs instead of the one
      # pinned here. Also the single definition of the package: the `packages`
      # output below is derived from it.
      overlays.default = final: prev:
        {
          encore = final.callPackage ./encore.nix { };
        }
        // nixpkgs.lib.optionalAttrs (alphaRelease != null) {
          encore-alpha = final.callPackage ./encore-v2.nix {
            channel = "alpha";
            release = alphaRelease;
          };
        }
        // nixpkgs.lib.optionalAttrs (betaRelease != null) {
          encore-beta = final.callPackage ./encore-v2.nix {
            channel = "beta";
            release = betaRelease;
          };
        }
        // nixpkgs.lib.optionalAttrs (nightlyRelease != null) {
          encore-nightly = final.callPackage ./encore-v2.nix {
            channel = "nightly";
            release = nightlyRelease;
          };
        };

      packages = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        in
        {
          encore = pkgs.encore;
          default = pkgs.encore;
        }
        // nixpkgs.lib.optionalAttrs (alphaRelease != null) {
          encore-alpha = pkgs.encore-alpha;
        }
        // nixpkgs.lib.optionalAttrs (betaRelease != null) {
          encore-beta = pkgs.encore-beta;
        }
        // nixpkgs.lib.optionalAttrs (nightlyRelease != null) {
          encore-nightly = pkgs.encore-nightly;
        });

      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      homeModules.default = { pkgs, ... } @ args:
        import ./hm-module.nix ({
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) encore;
        }
        // args);
    };
}
