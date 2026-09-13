-- =============================================================================
-- Lualine: the status line at the bottom of the window
-- =============================================================================
-- Shows the current mode, git branch, file name, diagnostics counts, and
-- cursor position — themed to match Gruvbox so the whole editor feels of a
-- piece. Purely informational; nothing to press.
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "gruvbox",
      icons_enabled = true,
      section_separators = "",   -- flat look; set to "" glyphs if you prefer
      component_separators = "|",
    },
    sections = {
      lualine_c = { { "filename", path = 1 } }, -- show the path relative to cwd
      lualine_x = { "diagnostics", "filetype" },
    },
  },
}
