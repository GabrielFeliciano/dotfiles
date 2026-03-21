{ pkgs, lib, ... }:

let
  neovimTools = with pkgs; [
    git
    fzf
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
    vscode-js-debug
  ];
in
{
  environment.systemPackages = [
    (pkgs.wrapNeovim pkgs.neovim-unwrapped {
      extraMakeWrapperArgs = "--prefix PATH : ${lib.makeBinPath neovimTools}";
      viAlias = true;
      vimAlias = true;
      configure = {
        customLuaRC = builtins.readFile ./init.lua;
        packages.myPlugins.start = with pkgs.vimPlugins; [
          # core
          plenary-nvim
          mini-nvim
          # completion
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          luasnip
          cmp_luasnip
          # lsp / formatting
          nvim-lspconfig
          conform-nvim
          lazydev-nvim
          # ui / navigation
          telescope-nvim
          telescope-fzf-native-nvim
          catppuccin-nvim
          no-neck-pain-nvim
          # git
          neogit
          diffview-nvim
          # notes
          obsidian-nvim
          # debug
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
          # misc
          snacks-nvim
          persisted-nvim
          vim-tmux-navigator
        ];
      };
    })
  ];

  environment.sessionVariables.EDITOR = "nvim";
  environment.pathsToLink = [ "/share/nvim" ];
}
