-- =============================================================================
-- Treesitter: real syntax understanding (not just regex highlighting)
-- =============================================================================
-- Neovim's built-in highlighting guesses with regexes. Treesitter instead
-- parses your code into a real syntax tree, so highlighting, indentation and
-- code-aware motions actually understand Go's grammar. It installs a small
-- parser per language on demand.
--
-- After first launch, check parsers with `:TSInstallInfo`. Nothing to press —
-- this just works in the background once installed.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate", -- recompile parsers whenever the plugin updates
  event = { "BufReadPre", "BufNewFile" }, -- load when you open a real file
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Parsers to keep installed. `go`, `gomod`, `gosum`, `gowork` cover the
      -- whole Go project surface; the rest are common companions.
      ensure_installed = {
        "go", "gomod", "gosum", "gowork",
        "lua", "vim", "vimdoc", "bash",
        "json", "yaml", "toml", "markdown", "markdown_inline",
        "dockerfile", "gitignore", "sql",
      },
      auto_install = true,      -- install a parser automatically for new filetypes
      highlight = { enable = true },
      indent = { enable = true }, -- treesitter-based `=` indentation
    })
  end,
}
