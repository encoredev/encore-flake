{
  description = "nix flake that wraps the released encore binaries";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
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
      overlays.default = final: prev: {
        encore = final.callPackage ./encore.nix { };
      };

      packages = eachSystem (system:
        let
          encore = (nixpkgs.legacyPackages.${system}.extend self.overlays.default).encore;
        in
        {
          encore = encore;
          default = encore;
        });

      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      homeModules.default = { pkgs, ... } @ args:
        import ./hm-module.nix ({
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) encore;
        }
        // args);
    };
}
