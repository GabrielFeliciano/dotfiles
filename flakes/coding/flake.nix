{
  description = "Coding NixOS configuration";

  inputs = {
    ai-jail.url = "github:akitaonrails/ai-jail";
  };

  outputs = { ai-jail, ... }: {
    nixosModules.default = { pkgs, ... }: {
      imports = [ ./configuration.nix ];
      _module.args.ai-jail = ai-jail;
    };
  };
}
