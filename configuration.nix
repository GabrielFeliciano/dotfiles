{
  pkgs,
  openaws-vpn-client,
  config,
  agenix,
  nix-vscode-extensions,
  ...
}:

let
  profiles = [
    "personal"
    "shared"
  ];

  importProfile =
    profile:
    if profile == "personal" then
      import ./configurations/personal.nix { inherit pkgs; }
    else if profile == "work" then
      import ./configurations/work.nix { inherit pkgs openaws-vpn-client nix-vscode-extensions; }
    else if profile == "shared" then
      import ./configurations/shared.nix { inherit pkgs agenix; }
    else
      {
        packages = [ ];
        neovimPackages = [ ];
      };

  importedProfiles = map importProfile profiles;

  profilePackages = builtins.concatMap (p: p.packages or [ ]) importedProfiles;
  profileNeovimPackages = builtins.concatMap (p: p.neovimPackages or [ ]) importedProfiles;
in

{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/home/gabriel/.config/sops/age/keys.txt";
    secrets.anthropic_api_key = {
      owner = "gabriel";
    };
  };

  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  # Enable OpenGL
  hardware = {
    graphics = {
      enable = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "nixos"
      "gabriel"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gabriel = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "remote"
      # "adbusers"
    ];
  };

  # Symlink neovim config - allows live editing without rebuild
  systemd.tmpfiles.rules = [
    "L+ /home/gabriel/.config/nvim - - - - /home/gabriel/nixos-config/dotfiles/neovim"
    "L+ /home/gabriel/.claude/settings.json - - - - ${./dotfiles/claude-settings.json}"
  ];

  environment.etc."gitconfig".text = ''
    [user]
      name = GabrielFeliciano
      email = gabriel.feliciano@olhonocarro.com.br
    [init]
      defaultBranch = main
    [pull]
      rebase = true
    [push]
      autoSetupRemote = true
      default = simple
    [rerere]
      enabled = true
    [branch]
      sort = -committerdate
    [core]
      autocrlf = false
    [diff]
      colorMoved = default
  '';

  environment = {
    systemPackages = profilePackages ++ profileNeovimPackages ++ [ pkgs.dunst ];
    variables = {
      XDG_CURRENT_DESKTOP = "GNOME";
      DONT_PROMPT_WSL_INSTALL = "1";
      GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      VSCODE_EXTENSIONS = "/home/gabriel/.vscode-extensions";
    };
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };

    direnv.enable = true;

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        sensible
        vim-tmux-navigator
        yank
      ];
      extraConfig = ''
        set -g @catppuccin_flavour 'mocha'
        set -g mouse on
        set -g prefix C-Space
        unbind C-b
        bind C-Space send-prefix
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        set-window-option -g mode-keys vi
        set-option -sa terminal-overrides ",xterm*:Tc"

        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Use Alt-arrow keys without prefix key to switch panes
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Shift Alt vim keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        # Vi copy-mode keybindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Split windows keeping current path
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      '';
    };

    bash.interactiveShellInit = ''
      eval "$(mise activate bash)";
      export ANTHROPIC_API_KEY="$(cat /run/secrets/anthropic_api_key)";
      export MANPAGER="nvim -c 'Man!' -"

      nv() {
        nvim . ;
      }

      nixrebuild() {
        sudo nixos-rebuild switch;
      }

      nvnix() {
        nvim ~/nixos-config/;
      }
    '';

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      protontricks.enable = true;
    };
    gamemode.enable = true;

    i3lock.enable = true;

    chromium = {
      enable = true;
      extensions = [
        "dabkegjlekdcmefifaolmdhnhdcplklo" # improve hacker news ui
        "dbepggeogbaibhgnhhndojpepiihcmeb"
        "nngceckbapebfimnlniiiahkandclblb"
        "opemhndcehfgipokneipaafbglcecjia"
      ];
    };

    # obs-studio = {
    #   enable = true;
    #   enableVirtualCamera = true;
    #   plugins = with pkgs.obs-studio-plugins; [
    #     droidcam-obs
    #   ];
    # };

    openvpn3.enable = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
  ];

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    udisks2.enable = true;
    gvfs.enable = true;

    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = true;
      dpi = 96;

      xkb = {
        layout = "us";
        variant = "altgr-intl";
        #options = "lv3:ralt_alt";
      };

      windowManager.i3 = {
        enable = true;

        extraPackages = with pkgs; [
          dmenu
          i3status
          i3blocks
        ];
      };

      videoDrivers = [ "nvidia" ];
    };

    xrdp = {
      enable = true;
      defaultWindowManager = "i3";
      openFirewall = true;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
    firewall.enable = false;
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };
}

