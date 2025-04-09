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
      packages = eachSystem (system:
        let
          encore = nixpkgs.legacyPackages.${system}.callPackage ./encore.nix { };
        in
        {
          encore = encore;
          default = encore;
        });

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      homeModules.default = { pkgs, ... } @ args:
        import ./hm-module.nix ({
          inherit (self.packages.${pkgs.system}) encore;
        }
        // args);
    };
}
