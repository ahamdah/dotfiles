-- =============================================================================
-- Theme: Gruvbox — matches your iTerm2/tmux setup
-- =============================================================================
-- A "plugin spec" is a Lua table describing one plugin. Returning it from a
-- file in lua/plugins/ is all lazy.nvim needs to install and load it.
return {
  "ellisonleao/gruvbox.nvim", -- GitHub repo: author/name
  lazy = false,     -- load immediately at startup (themes must — otherwise
                    -- you'd see a flash of unstyled editor first)
  priority = 1000,  -- load before all other plugins so they pick up its colors
  config = function()
    require("gruvbox").setup({
      contrast = "hard", -- "hard" | "" (medium) | "soft" — try them!
    })
    vim.cmd.colorscheme("gruvbox")
  end,
}
