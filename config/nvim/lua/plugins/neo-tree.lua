-- =============================================================================
-- Neo-tree: the file explorer sidebar (the one from the videos)
-- =============================================================================
-- Toggle it with <Space>e. Inside the tree:
--   j/k move · Enter opens · Space expands a folder · ? shows ALL keys
--   a add file · d delete · r rename · c copy · x cut · p paste
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",        -- utility library many plugins share
    "nvim-tree/nvim-web-devicons",  -- the file-type icons (needs a Nerd Font)
    "MunifTanjim/nui.nvim",         -- UI-component library neo-tree draws with
  },
  -- `keys` = lazy-loading trigger: the plugin isn't even loaded until the
  -- first time you press <Space>e. Faster startup for free.
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File explorer" },
    -- Cmd+` (forwarded by iTerm2 as Alt+`, i.e. <M-`>) toggles the tree from
    -- ANY mode. Opening focuses the tree so you can navigate right away;
    -- pressing it again closes it. `<cmd>…<cr>` runs without leaving your mode,
    -- so it works even mid-typing in insert mode.
    {
      "<M-`>",
      "<cmd>Neotree toggle<cr>",
      mode = { "n", "i", "v", "t" },
      desc = "File explorer (Cmd+`)",
    },
  },
  opts = {
    filesystem = {
      follow_current_file = { enabled = true }, -- highlight the open file
      filtered_items = {
        hide_dotfiles = false, -- you live in a dotfiles repo — show them!
      },
    },
    window = {
      mappings = {
        -- Cmd+n (forwarded by iTerm as <M-n>) pops up a menu of file actions
        -- on the item under the cursor. Each choice just triggers neo-tree's
        -- own built-in key for that action (a/A/r/d/c/m/x/p), so behaviour is
        -- identical to pressing those keys directly — this is the discoverable
        -- "list" in front of them.
        ["<M-n>"] = function()
          local actions = {
            { label = "New file…",    key = "a" },
            { label = "New folder…",  key = "A" },
            { label = "Rename…",      key = "r" },
            { label = "Delete",       key = "d" },
            { label = "Copy…",        key = "c" },
            { label = "Move…",        key = "m" },
            { label = "Cut",          key = "x" },
            { label = "Paste",        key = "p" },
          }
          vim.ui.select(actions, {
            prompt = "File action:",
            format_item = function(a) return a.label end,
          }, function(choice)
            if choice then
              -- feed the built-in neo-tree key; "m" allows its mapping to run
              vim.api.nvim_feedkeys(choice.key, "m", false)
            end
          end)
        end,
      },
    },
  },
}
