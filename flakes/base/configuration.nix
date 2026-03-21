{ pkgs, ... }:

{
  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

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

  users.users.gabriel = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "remote"
    ];
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
    firewall.enable = true;
  };

  virtualisation.docker.enable = true;

  environment.sessionVariables = {
    SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    udisks2.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "dabkegjlekdcmefifaolmdhnhdcplklo"
      "dbepggeogbaibhgnhhndojpepiihcmeb"
      "nngceckbapebfimnlniiiahkandclblb"
      "opemhndcehfgipokneipaafbglcecjia"
    ];
  };

  programs.bash.interactiveShellInit = ''
    export MANPAGER="nvim -c 'Man!' -"

    nixr() {
      sudo nixos-rebuild switch;
    }
  '';

  environment = {
    etc."gitconfig".text = ''
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
    systemPackages = with pkgs; [
      gnumake42
      direnv
      fzf
      lsof
      socat
      jq
      alacritty
      sesh
      nh
      nix-search
      playerctl
      age
      aichat
      htop
      unar
      obsidian
      pavucontrol
      google-chrome
      stow
      alsa-utils
      gnome-screenshot
      gnome-themes-extra
      xfce.thunar
      dzen2
      gtk3
      lxappearance
      xdg-desktop-portal-gtk
      git
    ];
  };
}
