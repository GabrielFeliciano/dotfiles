{
  description = "A simple NixOS flake";

  inputs = {
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix-cli.url = "github:ryantm/agenix";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openaws-vpn-client.url = "github:JonathanxD/openaws-vpn-client";
    sops-nix.url = "github:Mic92/sops-nix";
    base.url = "path:./flakes/base";
    coding.url = "path:./flakes/coding";
    personal.url = "path:./flakes/personal";
  };

  outputs =
    {
      nixpkgs,
      agenix,
      nix-vscode-extensions,
      openaws-vpn-client,
      sops-nix,
      alacritty-theme,
      base,
      coding,
      personal,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit
            nix-vscode-extensions
            agenix
            openaws-vpn-client
            ;
        };
        modules = [
          (
            { config, pkgs, ... }:
            {
              # install the overlay
              nixpkgs.overlays = [ alacritty-theme.overlays.default ];
            }
          )
          agenix.nixosModules.default
          sops-nix.nixosModules.sops
          base.nixosModules.default
          coding.nixosModules.default
          personal.nixosModules.default
          ./hardware-configuration.nix
        ];
      };
    };
}
