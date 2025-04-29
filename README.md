# :snowflake: encore-flake

A flake for simplifying installation of the released encore binaries on nix systems.

Try it out by simply running

```shell
$ nix run github:encoredev/encore-flake
```

## Usage

Add as an input in your nix configuration flake

```nix
{
  inputs = {
    # other inputs...
    encore = {
      url = "github:encoredev/encore-flake";
      # optional
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### Only the CLI

Import `encore.packages.default` into your nixos configuration

```nix
# Home manager
home.packages = [
  inputs.encore.packages.${pkgs.system}.encore
];

# NixOS configuration
environment.systemPackages = [
  inputs.encore.packages.${pkgs.system}.encore
];
```

### In a Development Shell

Add a `flake.nix` file in to your Encore project folder and include `encore` in the available command line tools for that project/folder using the `outputs` function.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils"
    encore = {
      url = "github:encoredev/encore-flake";
      # optional
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # other inputs...
  };

  outputs = { self, nixpkgs, flake-utils, encore, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        encorePkg = encore.packages.${system}.default;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            encorePkg
            git
            go
            # other outputs...
          ];
       };
     });  
}
```

then run `nix develop` from the project folder to enter the development shell for your project that will now include the `encore` CLI in the tool chain.

### With Home manager

Import `encore.homeModules.default` into your home manager config

```nix
imports = [
  inputs.encore.homeModules.default
];
```

and use the `programs.encore` options

```nix
{
  programs.encore = {
    enable = true;
    settings = {
      browser = "never";
    };
  };
}
```

You can then keep it up to date by running

```shell
$ nix flake update encore
```
