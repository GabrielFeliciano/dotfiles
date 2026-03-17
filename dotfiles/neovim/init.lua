local add, now, later = require("mini-deps").setup()

local deps = {
  {
    source = "epwalsh/obsidian.nvim",
    depends = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
  },
  {
    source = "neovim/nvim-lspconfig",
  },
  {
    source = "folke/snacks.nvim",
  },
  {
    source = "folke/lazydev.nvim",
  },
  {
    source = "stevearc/conform.nvim",
  },
  {
    source = "shortcuts/no-neck-pain.nvim",
  },
  {
    source = "pocco81/true-zen.nvim",
  },
  {
    source = "folke/zen-mode.nvim",
  },
  {
    source = "catppuccin/nvim",
    name = "catppuccin",
  },
  {
    source = "olimorris/persisted.nvim",
  },
  {
    source = "NeogitOrg/neogit",
    depends = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
  },
  {
    source = "yetone/avante.nvim",
    depends = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick",
      "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "HakonHarnes/img-clip.nvim",
    },
  },
  {
    source = "hrsh7th/nvim-cmp",
    depends = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "echasnovski/mini.snippets",
      "abeldekat/cmp-mini-snippets",
    },
  },
}

for _, dep in ipairs(deps) do
  add(dep)
end

-- config

vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.relativenumber = true
vim.g.mapleader = " "
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    vim.cmd("wincmd L")
  end,
})

-- Setups

later(function()
  require("obsidian").setup({
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian-personal-v2/",
        overrides = {
          new_notes_location = "Inbox",
          daily_notes = {
            folder = "Journal/Daily",
            date_format = "%Y-%m-%d",
            template = nil,
          },
        },
      },
    },
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    picker = {
      name = "mini.pick",
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },
    attachments = {
      img_folder = "attachments",
    },
  })
end)

later(function()
  require("snacks").setup()
end)

-- doesnt work
later(function()
  require("persisted").setup({
    autostart = true,
    autoload = true,
    on_autoload_no_session = function()
      vim.notify("No existing session to load.")
    end,
  })
end)

later(function()
  require("neogit").setup({
    -- Cute neogit configuration 💖
    integrations = {
      diffview = true,
    },
    graph_style = "unicode",
  })
  
  vim.keymap.set("n", "<leader>g", "<cmd>Neogit<cr>", { desc = "Open Neogit 🌸" })
  vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Git commit 💖" })
  vim.keymap.set("n", "<leader>gp", "<cmd>Neogit push<cr>", { desc = "Git push ✨" })
end)

later(function()
  require("catppuccin").setup({
    flavour = "mocha",
  })

  vim.cmd("colorscheme catppuccin")
end)

later(function()
  local NoNeckPain = require("no-neck-pain")

  NoNeckPain.setup({
    width = 120,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesExplorerClose",
    callback = function()
      NoNeckPain.enable()
    end,
  })

  NoNeckPain.enable()
end)

later(function()
  local MiniTabLine = require("mini.tabline")

  MiniTabLine.setup()
end)

later(function()
  local MiniStatusLine = require("mini.statusline")

  MiniStatusLine.setup()
end)

later(function()
  local MiniPick = require("mini.pick")
  local MiniExtraPickers = require("mini.extra").pickers

  local function useExtraPicker(pick, ...)
    local args = { ... }
    return function()
      MiniExtraPickers[pick](unpack(args))
    end
  end

  MiniPick.registry.registry = function()
    local items = vim.tbl_keys(MiniPick.registry)
    table.sort(items)
    local source = { items = items, name = "Registry", choose = function() end }
    local chosen_picker_name = MiniPick.start({ source = source })
    if chosen_picker_name == nil then
      return
    end
    return MiniPick.registry[chosen_picker_name]()
  end

  vim.keymap.set(
    "n",
    "<leader>s",
    useExtraPicker("lsp", { scope = "workspace_symbol" })
  )
  -- vim.keymap.set("n", "<leader>f", MiniExtraPickers.)
  vim.keymap.set("n", "<leader>pp", "<cmd>:Pick registry<cr>")
  vim.keymap.set("n", "<c-space>", "<cmd>:Pick buffers<cr>")
  vim.keymap.set("n", "<c-tab>", "<cmd>:Pick files<cr>")
  vim.keymap.set("n", "<c-f>", "<cmd>:Pick grep_live<cr>")

  -- not working
  vim.keymap.set("n", "<leader>z", function()
    local repositoriesPath = vim.fn.expand("~/repositories")
    local availableRepositories = vim.fn.readdir(repositoriesPath)
    local chosenRepoName =
      MiniPick.start({ source = { items = availableRepositories } })
    local chosenRepoPath = vim.fs.joinpath(repositoriesPath, chosenRepoName)
    vim.cmd("%bd|e#")
    vim.api.nvim_set_current_dir(chosenRepoPath)
  end)

  -- vim.keymap.set("n", "<leader>gb", MiniExtraPickers.)
  -- vim.keymap.set("n", "<leader>gc", MiniExtraPickers.)

  MiniPick.setup({
    window = {
      config = function()
        local height = math.floor(0.618 * vim.o.lines)
        local width = math.floor(0.618 * vim.o.columns)
        return {
          anchor = "NW",
          height = height,
          width = width,
          row = math.floor(0.5 * (vim.o.lines - height)),
          col = math.floor(0.5 * (vim.o.columns - width)),
        }
      end,
    },
  })
end)

later(function()
  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
    }, {
      { name = "buffer" },
    }),
  })
end)

later(function()
  require("mini.cmdline").setup()
end)

function minisetup()
  local MiniFiles = require("mini.files")
  MiniFiles.setup({
    options = {
      permanent_delete = true,
      use_as_default_explorer = false,
    },
  })

  vim.keymap.set("n", "<c-e>", MiniFiles.open)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "minifiles",
    callback = function()
      vim.keymap.set("n", "<Esc>", function()
        require("mini.files").close()
      end, { buffer = true, desc = "Close mini.files" })
    end,
  })
end

minisetup()

later(function()
  require("mini.diff").setup()
end)

later(function()
  -- use defaults https://nvim-mini.org/mini.nvim/doc/mini-comment.html#mini.comment
  require("mini.comment").setup({
    options = {
      -- Function to compute custom 'commentstring' (optional)
      custom_commentstring = nil,
      -- Whether to ignore blank lines in actions and textobject
      ignore_blank_line = false,
      -- Whether to recognize as comment only lines without indent
      start_of_line = false,
      -- Whether to force single space inner padding for comment parts
      pad_comment_parts = true,
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Toggle comment (like `gcip` - comment inner paragraph) for both
      -- Normal and Visual modes
      comment = "gc",
      -- Toggle comment on current line
      comment_line = "gcc",
      -- Toggle comment on visual selection
      comment_visual = "gc",
      -- Define 'comment' textobject (like `dgc` - delete whole comment block)
      -- Works also in Visual mode if mapping differs from `comment_visual`
      textobject = "gc",
    },
  })
end)

later(function()
  local miniclue = require("mini.clue")
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = { "n", "x" }, keys = "<Leader>" },

      -- `[` and `]` keys
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },

      -- Built-in completion
      { mode = "i", keys = "<C-x>" },

      -- Other Built-in
      { mode = "n", keys = "<C-w>" },

      -- `g` key
      { mode = { "n", "x" }, keys = "g" },

      -- Marks
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },

      -- Registers
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },

      -- Window commands
      { mode = "n", keys = "<C-w>" },

      -- `z` key
      { mode = { "n", "x" }, keys = "z" },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end)

later(function()
  local animate = require("mini.animate")
  animate.setup({
    scroll = {
      timing = animate.gen_timing.linear({ duration = 120, unit = "total" }),
      subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 }),
    },
  })

  animate.setup({
    cursor = {
      -- Animate for 200 milliseconds with linear easing
      timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),

      -- Animate with shortest line for any cursor move
      path = animate.gen_path.line({
        predicate = function()
          return true
        end,
      }),
    },
  })
end)

later(function()
  conform = require("conform")
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "isort", "black" },
      -- You can customize some of the format options for the filetype (:help conform.format)
      rust = { "rustfmt", lsp_format = "fallback" },
      -- Conform will run the first available formatter
      javascript = { "prettierd", "prettier", stop_after_first = true },
      nix = { "nixfmt" },
      html = { "html_beautify" },
      css = { "stylelint" },
    },
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
      conform.format({ bufnr = args.buf })
    end,
  })
end)

later(function()
  require("lazydev").setup()

  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        runtime = {
          version = "LuaJIT",
        },
      },
    },
  })

  vim.lsp.config("biome", {
    cmd = { "/run/current-system/sw/bin/biome", "lsp-proxy" },
  })

  vim.lsp.enable("lua_ls")
  vim.lsp.enable("nil_ls")
  vim.lsp.enable("vtsls")
  -- vim.lsp.enable("ts_ls")
  vim.lsp.enable("biome")
end)

later(function()
  require("avante").setup({
    input = {
      provider = "snacks",
    },
    provider = "claude-code",
    mappings = {
      toggle = {
        default = "<C-t>",
      },
    },
    acp_providers = {
      ["claude-code"] = {
        command = "claude-code-acp",
        args = { "--permission-mode", "default" },
        env = {
          ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
        },
      },
    },
  })

  vim.keymap.set({ "n", "i", "v" }, "<C-t>", function()
    require("avante.api").toggle()
  end, { desc = "Avante: toggle chat" })
end)