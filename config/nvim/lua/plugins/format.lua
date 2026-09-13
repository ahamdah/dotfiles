-- =============================================================================
-- Formatting: tidy code + manage imports on every save (conform.nvim)
-- =============================================================================
-- Go has one canonical style, so formatting should be automatic and invisible.
-- On save, conform runs `goimports` (which formats AND adds/removes import
-- lines) then `gofumpt` (a stricter gofmt). You never think about it again.
--
-- Manual format any time with <leader>f. Tools come from Mason (see mason.lua).
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- load just before the first save
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      mode = "n",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" }, -- run in this order
    },
    -- Format automatically when you save the file
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback", -- if no formatter is configured, ask the LSP
    },
  },
}
