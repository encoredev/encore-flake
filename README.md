# :snowflake: encore-flake

A flake for simplifying installation of the released encore binaries on nix systems.

Try it out by simply running
```
$ nix run github:encoredev/encore-flake
```

## Usage

Add as an input in your nix configuration flake, and add as an overlay to nixpkgs

```nix
{
  inputs = [
    encore.url = "github:encoredev/encore-flake";
  ];
}
```

You can then keep it up to date by running 
```
$ nix flake lock --update-input encore
```
