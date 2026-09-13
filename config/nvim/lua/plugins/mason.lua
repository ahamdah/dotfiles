-- =============================================================================
-- Mason: a package manager for editor tools (LSP servers, formatters, debuggers)
-- =============================================================================
-- Mason downloads command-line tools into ~/.local/share/nvim/mason/ and, when
-- it initializes, prepends that bin/ directory to Neovim's PATH — so gopls,
-- delve, etc. are found without a global `brew install`. mason-tool-installer
-- then makes sure the exact tools we need are present, installing any that are
-- missing. This is what makes the Go setup "just work" on a fresh machine.
--
-- IMPORTANT: because Mason edits Neovim's PATH, it must load BEFORE the LSP
-- starts. lsp.lua lists mason.nvim as a dependency, which guarantees that.
--
-- Open the UI any time with `:Mason` — press `i` to install, `X` to uninstall.
return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  cmd = "Mason",
  config = function()
    require("mason").setup({
      ui = { border = "rounded" },
    })

    require("mason-tool-installer").setup({
      -- Everything the Go IDE needs, installed automatically:
      ensure_installed = {
        "gopls",        -- the Go language server (completion, go-to-def, errors)
        "goimports",    -- formats + auto-manages import lines
        "gofumpt",      -- stricter gofmt used by gopls formatting
        "delve",        -- the Go debugger (dlv) that nvim-dap drives
        "staticcheck",  -- extra lint/analysis surfaced through gopls
      },
      run_on_start = true, -- check/install when Mason loads
    })
  end,
}
