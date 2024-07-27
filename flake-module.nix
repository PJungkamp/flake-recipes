toplevel @ {
  flake-parts-lib,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf mapAttrs;
  inherit (flake-parts-lib) mkSubmoduleOptions mkPerSystemOption;

  perSystemOptions = mkPerSystemOption ({
    config,
    pkgs,
    ...
  }: {
    options.recipes.packages = {
      enable = mkEnableOption "package outputs for all recipes";

      pkgs = mkOption {
        type = with types; lazyAttrsOf types.unspecified;
        default = pkgs;
        defaultText = "pkgs (module argument)";
      };

      args = mkOption {
        type = with types; lazyAttrsOf types.unspecified;
        default = {};
      };
    };

    config.packages = let
      cfg = config.recipes.packages;
      callPackage = lib.customisation.callPackageWith (cfg.pkgs // packages);
      packages =
        mapAttrs
        (name: recipe: callPackage recipe cfg.args)
        toplevel.config.flake.recipes;
    in
      mkIf cfg.enable packages;
  });
in {
  options = {
    recipes.overlay = {
      enable = mkEnableOption "overlay containing all recipes";

      name = mkOption {
        type = types.str;
        default = "recipes";
      };

      args = mkOption {
        type = with types; lazyAttrsOf types.unspecified;
        default = {};
      };
    };

    flake = mkSubmoduleOptions {
      recipes = mkOption {
        type = with types; attrsOf (uniq unspecified);
        default = {};
      };
    };

    perSystem = perSystemOptions;
  };

  config.flake.overlays = let
    cfg = config.recipes.overlay;
  in
    mkIf cfg.enable {
      ${cfg.name} = final: prev: (
        mapAttrs
        (name: recipe: final.callPackage recipe cfg.args)
        config.flake.recipes
      );
    };
}
