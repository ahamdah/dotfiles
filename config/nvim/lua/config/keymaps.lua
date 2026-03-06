-- =============================================================================
-- keymaps.lua — Neovim key mappings
-- =============================================================================
local map = vim.keymap.set

-- Leader key
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Better defaults ───────────────────────────────────────────────────────────
map("n", "<Esc>",       "<cmd>nohlsearch<cr>",   { desc = "Clear search highlights" })
map("n", "U",           "<C-r>",                 { desc = "Redo" })
map("v", "<",           "<gv",                   { desc = "Indent left (keep selection)" })
map("v", ">",           ">gv",                   { desc = "Indent right (keep selection)" })
map("n", "J",           "mzJ`z",                 { desc = "Join lines (keep cursor)" })
map("n", "<C-d>",       "<C-d>zz",               { desc = "Scroll down (centered)" })
map("n", "<C-u>",       "<C-u>zz",               { desc = "Scroll up (centered)" })
map("n", "n",           "nzzzv",                 { desc = "Next search (centered)" })
map("n", "N",           "Nzzzv",                 { desc = "Prev search (centered)" })

-- ── Clipboard ─────────────────────────────────────────────────────────────────
map({ "n", "v" }, "<leader>y", '"+y',   { desc = "Yank to system clipboard" })
map("n",          "<leader>Y", '"+Y',   { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>d", '"_d',   { desc = "Delete without yanking" })
map("x",          "<leader>p", '"_dP',  { desc = "Paste without overwriting register" })

-- ── Files ─────────────────────────────────────────────────────────────────────
map("n", "<leader>w",  "<cmd>w<cr>",      { desc = "Save file" })
map("n", "<leader>q",  "<cmd>q<cr>",      { desc = "Quit" })
map("n", "<leader>Q",  "<cmd>qa!<cr>",    { desc = "Force quit all" })

-- ── Buffers ───────────────────────────────────────────────────────────────────
map("n", "<S-h>",      "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>",      "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bd<cr>",        { desc = "Delete buffer" })

-- ── Splits ────────────────────────────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<cr>",  { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>",   { desc = "Horizontal split" })
map("n", "<C-h>",      "<C-w>h",           { desc = "Move to left pane" })
map("n", "<C-j>",      "<C-w>j",           { desc = "Move to lower pane" })
map("n", "<C-k>",      "<C-w>k",           { desc = "Move to upper pane" })
map("n", "<C-l>",      "<C-w>l",           { desc = "Move to right pane" })
map("n", "<C-Up>",     "<cmd>resize +2<cr>",          { desc = "Increase height" })
map("n", "<C-Down>",   "<cmd>resize -2<cr>",          { desc = "Decrease height" })
map("n", "<C-Left>",   "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>",  "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>",  { desc = "Exit terminal mode" })
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })
