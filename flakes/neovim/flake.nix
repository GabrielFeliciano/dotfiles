{
  description = "Neovim NixOS configuration";
  outputs = { ... }: {
    nixosModules.default = import ./configuration.nix;
  };
}
