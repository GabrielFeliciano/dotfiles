{ pkgs }:

{
  packages = with pkgs; [
    discord
    localsend
    vial
    megasync
  ];

  services = {
    xrdp = {
      enable = true;
      defaultWindowManager = "i3";
      openFirewall = true;
    };
  };
}
