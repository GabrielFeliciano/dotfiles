{ pkgs, agenix }:
let
  claude-code-patched = pkgs.claude-code.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [ ])
      ++ (with pkgs; [
        autoPatchelfHook
        makeWrapper
      ]);
    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/claude \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.libnotify ]}
    '';
    buildInputs =
      (old.buildInputs or [ ])
      ++ (with pkgs; [
        libseccomp
        stdenv.cc.cc.lib # libstdc++.so.6 and libgcc_s.so.1
      ]);
    # sharp bundles musl variants for Alpine Linux — they're unused on glibc NixOS
    autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];
  });
in
{
  neovimPackages = with pkgs; [
    claude-code-acp
    js-beautify
    vtsls
    typescript-language-server
    nil
    lua-language-server
    stylua
    biome
    xclip
    nixfmt-rfc-style
    ripgrep
  ];

  packages = with pkgs; [
    # may remove
    gnumake42
    gcc
    mise
    direnv
    fzf
    lsof
    socat
    jq

    # both
    age
    aichat
    htop
    claude-code-patched
    unar
    obsidian
    alacritty
    pavucontrol
    google-chrome
    stow
    alsa-utils
    gnome-screenshot
    pkgs.gnome-themes-extra
    agenix.packages.${pkgs.system}.default
    xfce.thunar
    dzen2
    gtk3
    lxappearance
    xdg-desktop-portal-gtk
  ];
}
