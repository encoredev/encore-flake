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
      # recommended: builds encore against your own nixpkgs instead of
      # pulling a second one into your flake.lock
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
  inputs.encore.packages.${pkgs.stdenv.hostPlatform.system}.encore
];

# NixOS configuration
environment.systemPackages = [
  inputs.encore.packages.${pkgs.stdenv.hostPlatform.system}.encore
];
```

### Alpha and beta releases

Alpha and beta are independent v2 release channels. Once a channel has its first
published release, run it with:

```shell
nix run github:encoredev/encore-flake#encore-alpha -- --version
nix run github:encoredev/encore-flake#encore-beta -- --version
```

Install them together with stable using:

```nix
home.packages = with inputs.encore.packages.${pkgs.stdenv.hostPlatform.system}; [
  encore
  encore-alpha
  encore-beta
];
```

The commands are `encore`, `encore-alpha`, and `encore-beta`, respectively. Each
v2 package keeps its Go toolchain, runtimes, and SDK modules in its own `libexec`
directory. The overlay exposes the same package names; the default package and
Home Manager module continue to select stable.

`release.nix`, `release-alpha.nix`, and `release-beta.nix` track the channels
separately. Releaser updates only the selected channel's version and checksums
after uploading its archives. A `null` release record means the channel has not
published yet and its package is omitted from the flake and overlay outputs.
Update your flake lock to receive new releases.

### With an overlay

An overlay is also available:

```nix
{
  nixpkgs.overlays = [ inputs.encore.overlays.default ];
}
```

`encore` is then available as an ordinary package:

```nix
# NixOS configuration
environment.systemPackages = [ pkgs.encore ];

# Home manager
home.packages = [ pkgs.encore ];
```

### In a Development Shell

Add a `flake.nix` file in to your Encore project folder and include `encore` in the available command line tools for that project/folder using the `outputs` function.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    encore = {
      url = "github:encoredev/encore-flake";
      # recommended, see above
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
