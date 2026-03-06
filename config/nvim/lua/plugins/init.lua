-- =============================================================================
-- lua/plugins/ — Plugin specifications for lazy.nvim
-- All plugins are loaded lazily by default.
-- =============================================================================

return {
  -- ── Colorscheme ─────────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    lazy     = false,
    opts = {
      flavour               = "mocha",
      background            = { dark = "mocha" },
      transparent_background = false,
      integrations = {
        cmp       = true,
        gitsigns  = true,
        nvimtree  = true,
        telescope = { enabled = true },
        mini      = true,
        treesitter = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ── File Explorer ────────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" } },
    opts = {
      sort_by = "case_sensitive",
      view    = { width = 32 },
      renderer = { group_empty = true, icons = { show = { git = true } } },
      filters  = { dotfiles = false },
    },
  },

  -- ── Statusline ───────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {
      options = { theme = "catppuccin", globalstatus = true },
    },
  },

  -- ── Fuzzy Finder ────────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
    },
    config = function()
      require("telescope").setup({
        defaults = { file_ignore_patterns = { "node_modules", ".git/" } },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  -- ── Treesitter ───────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash", "c", "go", "html", "javascript", "json", "lua",
        "markdown", "python", "rust", "toml", "typescript", "yaml", "zsh",
      },
      highlight    = { enable = true },
      indent       = { enable = true },
      auto_install = true,
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- ── LSP ──────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "rust_analyzer", "gopls", "ts_ls" },
        automatic_installation = true,
      })
      local lspconfig = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(_, buf)
        local map = function(k, v, d) vim.keymap.set("n", k, v, { buffer = buf, desc = d }) end
        map("gd",         vim.lsp.buf.definition,      "Go to definition")
        map("gr",         vim.lsp.buf.references,      "References")
        map("K",          vim.lsp.buf.hover,            "Hover docs")
        map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
        map("<leader>rn", vim.lsp.buf.rename,           "Rename symbol")
        map("<leader>f",  vim.lsp.buf.format,           "Format file")
      end
      for _, server in ipairs({ "lua_ls", "pyright", "rust_analyzer", "gopls", "ts_ls" }) do
        lspconfig[server].setup({ capabilities = caps, on_attach = on_attach })
      end
    end,
  },

  -- ── Completion ───────────────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]   = cmp.mapping.select_next_item(),
          ["<C-p>"]   = cmp.mapping.select_prev_item(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"]   = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fb() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
          { name = "buffer" },   { name = "path" },
        }),
      })
    end,
  },

  -- ── Git ──────────────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add    = { text = "▎" }, change = { text = "▎" },
        delete = { text = "" }, topdelete = { text = "" },
      },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local map = function(k, v, d) vim.keymap.set("n", k, v, { buffer = buf, desc = d }) end
        map("]h", gs.next_hunk,        "Next hunk")
        map("[h", gs.prev_hunk,        "Previous hunk")
        map("<leader>hs", gs.stage_hunk,   "Stage hunk")
        map("<leader>hr", gs.reset_hunk,   "Reset hunk")
        map("<leader>hb", gs.blame_line,   "Blame line")
        map("<leader>hd", gs.diffthis,     "Diff this")
      end,
    },
  },

  -- ── Autopairs & Surround ─────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {},
  },
  {
    "kylechui/nvim-surround",
    event   = "VeryLazy",
    version = "*",
    opts    = {},
  },

  -- ── Comments ─────────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts  = {},
  },

  -- ── UI Polish ────────────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = { preset = "modern" },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main  = "ibl",
    opts  = { scope = { enabled = true } },
  },
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts         = { lsp = { override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    } } },
  },
}
