-- =============================================================================
-- LSP: the brains of the IDE (powered by gopls for Go)
-- =============================================================================
-- A Language Server is a background program that understands your code the way
-- a compiler does. gopls gives you: jump-to-definition, hover docs, rename,
-- find-references, live error diagnostics, and code actions (quick fixes).
--
-- nvim-lspconfig ships sensible connection recipes for each server; we just
-- turn gopls on and tune a few Go-specific options. The KEYBINDINGS below only
-- attach once a server is actually running in the buffer (the LspAttach event),
-- so they never fire in files with no language server.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim", -- load Mason FIRST so gopls is on PATH before we spawn it
    "saghen/blink.cmp",        -- so we can advertise completion capabilities to gopls
  },
  config = function()
    -- ── Keymaps: set only when an LSP attaches to the current buffer ─────────
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP keybindings",
      callback = function(event)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "List references")
        map("gI", vim.lsp.buf.implementation, "Go to implementation")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("K", vim.lsp.buf.hover, "Hover docs")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>D", vim.lsp.buf.type_definition, "Type definition")
        map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
        map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

        -- Highlight all uses of the symbol under the cursor while it rests there
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/documentHighlight") then
          local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf, group = group, callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf, group = group, callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- ── Diagnostics display (the red/yellow underlines and gutter signs) ─────
    vim.diagnostic.config({
      virtual_text = { spacing = 2 },   -- inline message at end of the line
      severity_sort = true,
      float = { border = "rounded", source = true },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN]  = "",
          [vim.diagnostic.severity.INFO]  = "",
          [vim.diagnostic.severity.HINT]  = "",
        },
      },
    })

    -- Tell servers which completion features our client (blink.cmp) supports,
    -- so gopls sends richer suggestions (snippets, auto-import edits, etc).
    -- Neovim 0.11 has native LSP config: `vim.lsp.config()` merges our options
    -- on top of the base recipe nvim-lspconfig ships (cmd, filetypes, root
    -- markers), and `vim.lsp.enable()` turns the server on. (The old
    -- `require('lspconfig').gopls.setup{}` framework is deprecated on 0.11.)
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- ── gopls: the Go language server ────────────────────────────────────────
    vim.lsp.config("gopls", {
      capabilities = capabilities,
      settings = {
        gopls = {
          gofumpt = true, -- stricter formatting on top of gofmt
          staticcheck = true, -- run the staticcheck analyzers
          usePlaceholders = true, -- fill function args as editable placeholders
          -- Limit workspace symbol search to YOUR project (not the stdlib and
          -- dependencies), so "Search Everywhere" stays clean like IntelliJ.
          symbolScope = "workspace",
          analyses = {
            unusedparams = true,
            unusedwrite = true,
            nilness = true,
            shadow = true,
            useany = true,
          },
          hints = { -- inlay hints: show inferred types & param names inline
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })
    vim.lsp.enable("gopls") -- actually start gopls for Go buffers

    -- Turn inlay hints on globally (toggle with the keymap below)
    vim.lsp.inlay_hint.enable(true)
    vim.keymap.set("n", "<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { desc = "Toggle inlay hints" })
  end,
}
