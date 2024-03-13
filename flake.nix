{
  description = "";

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs-lib,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      flake-parts-lib,
      self,
      ...
    }: let
      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
      };

      flakeModules.default = import ./flake-module.nix;
    in {
      systems = ["x86_64-linux"];

      flake = {
        inherit flakeModules lib;
      };
    });
}
