This is a NixOS system configuration repository. This repository is shared publicly, take care of secrets.

The configuration is split into 3 sub-flakes under `flakes/`, each with their own `flake.nix` and `configuration.nix`:

- `flakes/base/` — system foundation: nix settings, locale, time, users, boot, networking, docker, basic services, chromium, gitconfig
- `flakes/coding/` — dev environment: neovim, tmux, direnv, fonts, shell init, all dev/work packages
- `flakes/personal/` — home machine only: nvidia hardware, i3/xserver, gaming (steam), personal apps

The main `flake.nix` imports all 3. For a work machine, remove `personal.nixosModules.default` from the modules list.

This repo uses sops-nix to store secrets.
