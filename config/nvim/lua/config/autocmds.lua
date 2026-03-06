-- =============================================================================
-- autocmds.lua — Neovim auto commands
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on yank ─────────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- ── Remove trailing whitespace on save ────────────────────────────────────────
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- ── Return to last edit position ─────────────────────────────────────────────
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-resize panes when terminal is resized ────────────────────────────────
autocmd("VimResized", {
  group = augroup("ResizePanes", { clear = true }),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- ── Close certain filetypes with just q ──────────────────────────────────────
autocmd("FileType", {
  group = augroup("QuickClose", { clear = true }),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ── Set filetype-specific indentation ─────────────────────────────────────────
autocmd("FileType", {
  group = augroup("FileTypeIndent", { clear = true }),
  pattern = { "python", "rust" },
  callback = function() vim.opt_local.shiftwidth = 4; vim.opt_local.tabstop = 4 end,
})
