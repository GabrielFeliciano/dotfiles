{
  description = "Coding NixOS configuration";
  outputs = { ... }: {
    nixosModules.default = import ./configuration.nix;
  };
}
