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

  home-manager.users.gabriel =
    { pkgs, config, ... }:
    {
      home = {
        # file.".config" = {
        #   source = ./dotfiles;
        #   recursive = true;
        #   force = true;
        # };
        stateVersion = "25.05";
      };

      services.dunst.enable = true;

      programs = {
        neovim = {
          enable = true;
          defaultEditor = true;
          extraPackages = profileNeovimPackages;
        };

        direnv = {
          enable = true;
        };
        bash = {
          enable = true;
          bashrcExtra = ''
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

            #if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
            #  tmux attach-session -t default || tmux new-session -s default
            #fi
          '';
        };
        zoxide = {
          enable = true;
          enableBashIntegration = true;
        };
        git = {
          enable = true;
          userName = "GabrielFeliciano";
          userEmail = "gabriel.feliciano@olhonocarro.com.br";
          extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
            push.default = "simple";
            rerere.enabled = true;
            branch.sort = "-committerdate";
            core.autocrlf = false;
            diff.colorMoved = "default";
          };
        };
      };
    };

  environment = {
    systemPackages = profilePackages;
    variables = {
      XDG_CURRENT_DESKTOP = "GNOME";
      DONT_PROMPT_WSL_INSTALL = "1";
      GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      VSCODE_EXTENSIONS = "/home/gabriel/.vscode-extensions";
    };
  };

  programs = {
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

    tmux = {
      enable = true;
    };
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
