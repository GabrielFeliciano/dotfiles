{
  description = "Base NixOS configuration";
  outputs = { ... }: {
    nixosModules.default = import ./configuration.nix;
  };
}
