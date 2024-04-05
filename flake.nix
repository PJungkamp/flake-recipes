{
  description = "";

  outputs = {...}: {
    flakeModules.default = import ./flake-module.nix;
  };
}
