-- =============================================================================
-- which-key: press <Space> (or any prefix) and pause — a popup lists every
-- keybinding that continues from there, using the `desc` we put on each map.
-- Your living cheat-sheet; you never have to memorize shortcuts again.
-- =============================================================================
return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- load after startup finishes (no rush for a helper UI)
  opts = {},          -- empty opts = "use the defaults", which are great
}
