{
  pkgs,
  agenix,
  openaws-vpn-client,
  ...
}:

let
  seshSwitch = pkgs.writeShellScript "sesh-switch" ''
    sesh connect "$(fzf \
      --no-sort --ansi \
      --border-label ' sesh ' \
      --prompt '⚡  ' \
      --bind 'start:reload(sesh list -z)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(sesh list -z)' \
    )"
  '';

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
        stdenv.cc.cc.lib
        alsa-lib
      ]);
    autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];
  });
in

{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/gabriel/.config/sops/age/keys.txt";
    secrets.anthropic_api_key = {
      owner = "gabriel";
    };
  };

  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
  ];

  systemd.tmpfiles.rules = [
    "L+ /home/gabriel/.claude/settings.json - - - - /home/gabriel/nixos-config/dotfiles/claude-settings.json"
  ];

  programs = {
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

        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

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

        # sesh session switcher
        bind f display-popup -E "${seshSwitch}"
      '';
    };

    bash.interactiveShellInit = ''
      export MANPAGER="nvim -c 'Man!' -"

      nixr() {
        sudo nixos-rebuild switch;
      }
    '';

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  environment.systemPackages =
    (with pkgs; [
      # work tools
      keepassxc
      doppler
      redis
      sqlitebrowser
      kubectl
      k9s
      httptoolkit
      mongodb-compass
      go-task
      ngrok
      devenv
      dbeaver-bin
      gh
      awscli2
      vault
    ])
    ++ [
      claude-code-patched
      agenix.packages.${pkgs.system}.default
      openaws-vpn-client.defaultPackage.${pkgs.system}
    ];
}
