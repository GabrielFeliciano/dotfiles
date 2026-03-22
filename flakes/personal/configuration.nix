{ pkgs, config, ... }:

{
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services = {
    displayManager.defaultSession = "none+i3";

    xserver = {
      enable = true;
      dpi = 96;

      displayManager.setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 1920x1080
      '';

      xkb = {
        layout = "us";
        variant = "altgr-intl";
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

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      protontricks.enable = true;
    };
    gamemode.enable = true;
    i3lock.enable = true;
  };

  environment = {
    variables = {
      VSCODE_EXTENSIONS = "/home/gabriel/.vscode-extensions";
    };

    systemPackages = with pkgs; [
      discord
      localsend
      vial
      megasync
      dunst
    ];
  };
}
