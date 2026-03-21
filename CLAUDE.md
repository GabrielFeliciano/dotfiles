# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Build without switching (test build)
sudo nixos-rebuild build --flake .#nixos

# Update flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs

# Check flake outputs
nix flake show

# Format Nix files
nixfmt-rfc-style <file.nix>

# Encrypt/edit secrets
sops secrets/secrets.yaml
```

## Architecture

The configuration is split into 4 purpose-built flake modules under `flakes/`, each exposing `nixosModules.default`. The root `flake.nix` composes them all into a single `nixosConfigurations.nixos` output.

### Module Breakdown

| Module | Path | Purpose |
|--------|------|---------|
| `base` | `flakes/base/` | Core system: boot, networking, locale (pt_BR/America/Sao_Paulo), user `gabriel`, Docker, Git config |
| `coding` | `flakes/coding/` | Dev tools: tmux, direnv, zoxide, Claude Code, work packages (k8s, AWS, etc.), SOPS secrets |
| `neovim` | `flakes/neovim/` | Neovim + all plugins/LSPs declared in Nix (no plugin manager) |
| `personal` | `flakes/personal/` | Desktop: NVIDIA, i3wm on X11, Steam/gaming, Alacritty terminal config |

### Secrets Management

Secrets use `sops-nix` with age encryption. The age key lives outside the repo. Encrypted values are in `secrets/secrets.yaml`. The Anthropic API key is the main secret, injected into the environment via the `coding` flake.

### Neovim Plugins

All 23 plugins are managed as NixOS packages — there is no runtime plugin manager (no lazy.nvim/packer). Adding a plugin requires declaring it in `flakes/neovim/flake.nix` and referencing it in the config. The Lua config lives at `dotfiles/neovim/init.lua`.

### Hardware

Single host configuration targeting AMD x86_64 hardware with NVIDIA discrete GPU. Hardware-specific config is in `hardware-configuration.nix` (generated, do not edit manually). NVIDIA uses the stable driver with modesetting.

### Key External Inputs

- `nixpkgs`: unstable channel
- `agenix`: secrets management alternative (imported but `sops-nix` is the active secrets system)
- `alacritty-theme`: provides Catppuccin Mocha theme for Alacritty
- `nix-vscode-extensions`: VS Code extension packages
- `openaws-vpn-client`: work VPN client
