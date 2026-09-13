-- =============================================================================
-- dressing.nvim: make selection & input popups look like a real IDE
-- =============================================================================
-- Neovim's built-in vim.ui.select (used by our Cmd+n file-action menu and by
-- LSP code actions) and vim.ui.input (used by neo-tree's rename / new-file
-- prompts) normally render as plain text in the bottom command line — easy to
-- miss. dressing.nvim upgrades both into centered floating windows: a real
-- selectable LIST for menus, and a tidy input box for prompts.
--
-- Nothing to configure or press — it just replaces those popups everywhere.
-- In a select list: j/k or arrows move · <Enter> choose · <Esc> cancel.
return {
  "stevearc/dressing.nvim",
  event = "VeryLazy", -- load shortly after startup so the hooks are in place
  opts = {},
}
