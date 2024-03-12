{
  description = "";

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    flake-discover = {
      url = "github:PJungkamp/flake-discover";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    flake-discover,
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

      flakeModules = {
        default = import ./flake-module.nix;

        discover = flake-discover.lib.mkDiscoverModule {
          name = "recipes";
          path = ["flake"];
        };
      };
    in {
      systems = ["x86_64-linux"];

      flake = {
        inherit flakeModules lib;
      };
    });
}
