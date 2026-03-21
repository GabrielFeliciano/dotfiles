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
    source = "nvim-telescope/telescope.nvim",
    depends = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },
  {
    source = "yetone/avante.nvim",
    depends = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-telescope/telescope.nvim",
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
  {
    source = "christoomey/vim-tmux-navigator",
  },
  {
    source = "mfussenegger/nvim-dap",
  },
  {
    source = "rcarriga/nvim-dap-ui",
    depends = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
  },
  {
    source = "theHamsta/nvim-dap-virtual-text",
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

vim.keymap.set(
  "n",
  "<leader>dd",
  vim.diagnostic.open_float,
  { desc = "Diagnostic float" }
)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })

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
      name = "telescope.nvim",
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
    integrations = {
      diffview = true,
    },
    graph_style = "unicode",
  })

  vim.keymap.set("n", "<leader>g", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
  vim.keymap.set(
    "n",
    "<leader>gc",
    "<cmd>Neogit commit<cr>",
    { desc = "Git commit" }
  )
  vim.keymap.set(
    "n",
    "<leader>gp",
    "<cmd>Neogit push<cr>",
    { desc = "Git push" }
  )
  vim.keymap.set(
    "n",
    "<leader>gb",
    "<cmd>DiffviewFileHistory %<cr>",
    { desc = "Git: file history" }
  )
  vim.keymap.set("n", "<leader>gh", function()
    require("mini.diff").toggle_overlay(0)
  end, { desc = "Git: toggle diff overlay" })
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
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")

  telescope.setup({})
  telescope.load_extension("fzf")

  vim.keymap.set("n", "<C-p>", builtin.git_files)
  vim.keymap.set("n", "<leader>pf", builtin.find_files)
  vim.keymap.set("n", "<leader>ps", builtin.live_grep)
  vim.keymap.set("n", "<leader>pb", builtin.buffers)
  vim.keymap.set("n", "<leader>pp", builtin.builtin)
  vim.keymap.set("n", "<leader>pws", builtin.lsp_workspace_symbols)

  vim.keymap.set("n", "<leader>z", function()
    local repositoriesPath = vim.fn.expand("~/repositories")
    builtin.find_files({
      prompt_title = "Switch Repository",
      cwd = repositoriesPath,
      find_command = { "find", repositoriesPath, "-mindepth", "1", "-maxdepth", "1", "-type", "d" },
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(prompt_bufnr)
          vim.cmd("%bd|e#")
          vim.api.nvim_set_current_dir(selection.value)
        end)
        return true
      end,
    })
  end)
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
      { mode = "n", keys = "<leader>p" },

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

-- later(function()
--   require("avante").setup({
--     input = {
--       provider = "snacks",
--     },
--     provider = "claude-code",
--     mappings = {
--       toggle = {
--         default = "<C-t>",
--       },
--     },
--     acp_providers = {
--       ["claude-code"] = {
--         command = "claude-code-acp",
--         args = { "--permission-mode", "default" },
--         env = {
--           ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
--         },
--       },
--     },
--   })
--
--   vim.keymap.set({ "n", "i", "v" }, "<C-t>", function()
--     require("avante.api").toggle()
--   end, { desc = "Avante: toggle chat" })
-- end)

later(function()
  local dap = require("dap")
  local dapui = require("dapui")

  -- vscode-js-debug adapter (installed via nix as vscode-js-debug, binary: js-debug)
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "js-debug",
      args = { "${port}" },
    },
  }

  -- Derive a stable debug port from a directory path so every project always
  -- gets the same inspector port — no manual management, no conflicts.
  local function debug_port(path)
    local hash = 0
    for i = 1, #path do
      hash = (hash * 31 + path:byte(i)) % 1000
    end
    return 9229 + hash -- range 9229–10228
  end

  local js_config = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      -- Attaches to the port derived from the current working directory.
      -- Start the service with <leader>dn or <leader>dm and this will connect.
      type = "pwa-node",
      request = "attach",
      name = "Attach (auto port for cwd)",
      port = function()
        return debug_port(vim.fn.getcwd())
      end,
      cwd = "${workspaceFolder}",
    },
    {
      -- Fallback: manually enter a port if needed
      type = "pwa-node",
      request = "attach",
      name = "Attach (enter port)",
      port = function()
        return tonumber(
          vim.fn.input("Debug port: ", tostring(debug_port(vim.fn.getcwd())))
        )
      end,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.javascript = js_config
  dap.configurations.typescript = js_config
  dap.configurations.javascriptreact = js_config
  dap.configurations.typescriptreact = js_config

  dapui.setup()
  require("nvim-dap-virtual-text").setup()

  -- auto open/close UI with debug session
  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close

  -- breakpoints & stepping
  vim.keymap.set(
    "n",
    "<leader>db",
    dap.toggle_breakpoint,
    { desc = "DAP: toggle breakpoint" }
  )
  vim.keymap.set(
    "n",
    "<leader>dc",
    dap.continue,
    { desc = "DAP: continue / start" }
  )
  vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: step into" })
  vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: step over" })
  vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP: step out" })
  vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "DAP: terminate" })
  vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: toggle UI" })

  -- Launch current file in a tmux pane on its deterministic debug port.
  -- Then attach with <leader>dc → "Attach (auto port for cwd)".
  vim.keymap.set("n", "<leader>dn", function()
    local file = vim.fn.expand("%:p")
    local port = debug_port(vim.fn.getcwd())
    vim.notify("Debug port: " .. port, vim.log.levels.INFO)
    vim.fn.system(
      "tmux split-window -h 'node --inspect="
        .. port
        .. " "
        .. file
        .. "; read'"
    )
  end, { desc = "DAP: run file in tmux pane" })

  -- Launch npm run dev in a tmux pane on its deterministic debug port.
  vim.keymap.set("n", "<leader>dm", function()
    local cwd = vim.fn.getcwd()
    local port = debug_port(cwd)
    vim.notify("Debug port: " .. port, vim.log.levels.INFO)
    vim.fn.system(
      "tmux split-window -h -c '"
        .. cwd
        .. "' 'npm run dev --node-options=--inspect="
        .. port
        .. "; read'"
    )
  end, { desc = "DAP: npm run dev in tmux pane" })
end)

later(function()
  vim.keymap.set(
    { "n" },
    "<C-h>",
    "<cmd>TmuxNavigateLeft<cr>",
    { desc = "window left" }
  )
  vim.keymap.set(
    { "n" },
    "<C-l>",
    "<cmd>TmuxNavigateRight<cr>",
    { desc = "window right" }
  )
  vim.keymap.set(
    { "n" },
    "<C-k>",
    "<cmd>TmuxNavigateUp<cr>",
    { desc = "window up" }
  )
  vim.keymap.set(
    { "n" },
    "<C-j>",
    "<cmd>TmuxNavigateDown<cr>",
    { desc = "window down" }
  )
end)
