{
  description = "A simple NixOS flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix-cli.url = "github:ryantm/agenix";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openaws-vpn-client.url = "github:JonathanxD/openaws-vpn-client";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      nixpkgs,
      agenix,
      nix-vscode-extensions,
      openaws-vpn-client,
      sops-nix,
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
          agenix.nixosModules.default
          sops-nix.nixosModules.sops
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
}
