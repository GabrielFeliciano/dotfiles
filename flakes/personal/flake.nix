{
  description = "Personal NixOS configuration";
  outputs = { ... }: {
    nixosModules.default = import ./configuration.nix;
  };
}
