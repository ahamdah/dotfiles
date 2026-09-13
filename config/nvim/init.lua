-- =============================================================================
-- init.lua — Lesson 1: options & keymaps, no plugins yet
-- =============================================================================
-- This is the first file Neovim loads. Everything here is plain Lua talking
-- to Neovim's built-in settings — the same things `:set number` etc. do,
-- just written in a file so they apply every time you start.
--
-- Three Lua namespaces you'll use constantly:
--   vim.g       → global variables (plugin settings, leader key)
--   vim.opt     → editor options (like :set, but scriptable)
--   vim.keymap  → key mappings
--
-- To see help for ANY option below: `:help 'number'` (option name in quotes).
-- =============================================================================

-- ── Leader key ───────────────────────────────────────────────────────────────
-- The "leader" is a prefix for your own custom shortcuts. Space is the popular
-- choice because it's a big key that does nothing useful in normal mode.
-- Must be set BEFORE any mapping that uses <leader>.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Line numbers ─────────────────────────────────────────────────────────────
vim.opt.number = true         -- show absolute number on the current line
vim.opt.relativenumber = true -- other lines show distance from cursor.
                              -- Why: `5j` jumps down 5 lines — relative numbers
                              -- let you read off the count instantly.

-- ── Indentation ──────────────────────────────────────────────────────────────
vim.opt.tabstop = 4        -- a <Tab> character displays as 4 columns
vim.opt.shiftwidth = 4     -- >> and auto-indent move by 4 columns
vim.opt.expandtab = true   -- pressing Tab inserts spaces, not a tab char
vim.opt.smartindent = true -- auto-indent new lines sensibly

-- ── Search ───────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true -- searches are case-insensitive...
vim.opt.smartcase = true  -- ...unless you type a capital letter
vim.opt.incsearch = true  -- jump to matches while typing the search
vim.opt.hlsearch = true   -- keep matches highlighted (clear with <Esc>, below)

-- ── Windows & scrolling ──────────────────────────────────────────────────────
vim.opt.splitright = true -- :vsplit opens the new window to the right
vim.opt.splitbelow = true -- :split opens below (both feel more natural)
vim.opt.scrolloff = 8     -- keep 8 lines visible above/below the cursor
vim.opt.wrap = false      -- don't wrap long lines

-- ── Files & undo ─────────────────────────────────────────────────────────────
vim.opt.undofile = true   -- persist undo history to disk — you can undo
                          -- changes even after closing and reopening a file
vim.opt.swapfile = false  -- swap files are more annoying than useful today

-- ── System integration ───────────────────────────────────────────────────────
vim.opt.clipboard = "unnamedplus" -- yank/paste uses the macOS clipboard,
                                  -- so `y` and Cmd+V work together
vim.opt.mouse = "a"               -- mouse works everywhere (fine while learning)

-- ── Appearance ───────────────────────────────────────────────────────────────
vim.opt.termguicolors = true -- 24-bit color (needed by every modern theme)
vim.opt.signcolumn = "yes"   -- always reserve the gutter column so text
                             -- doesn't shift when git/LSP signs appear
vim.opt.cursorline = true    -- highlight the line the cursor is on
-- (colorscheme is now set by the gruvbox plugin — see lua/plugins/theme.lua)

-- =============================================================================
-- Keymaps
-- =============================================================================
-- vim.keymap.set(mode, keys, action, opts)
--   mode: "n" normal, "i" insert, "v" visual, "t" terminal
--   desc: shows up in help/pickers later — always write one.

local map = vim.keymap.set

-- Clear search highlighting when you press Esc in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Move between split windows with Ctrl + h/j/k/l instead of Ctrl-w then a key
map("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })

-- In visual mode, J/K drag the selected lines down/up and re-indent
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centered when jumping half-pages or between search hits
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
map("n", "n", "nzzzv", { desc = "Next search hit, centered" })
map("n", "N", "Nzzzv", { desc = "Prev search hit, centered" })

-- When pasting over a selection, don't overwrite the clipboard with
-- the text you just replaced
map("v", "p", '"_dP', { desc = "Paste without yanking replaced text" })

-- Quick save
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- =============================================================================
-- Autocommands — run code when events happen
-- =============================================================================

-- Briefly flash the text you just yanked, so you can see what `y` grabbed
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- =============================================================================
-- Plugins — managed by lazy.nvim
-- =============================================================================
-- lazy.nvim downloads plugins from GitHub into ~/.local/share/nvim/lazy/
-- and loads them for you. The block below first installs lazy.nvim ITSELF
-- if it's missing ("bootstrapping") — so on a brand-new machine, this one
-- file is all you need; everything else self-installs on first launch.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Read every file in lua/plugins/ as a plugin spec.
  -- One plugin per file keeps the config easy to navigate as it grows.
  spec = { { import = "plugins" } },
  -- If a plugin isn't installed yet, use this theme during the install screen
  install = { colorscheme = { "gruvbox" } },
  -- Don't phone home checking for updates; run :Lazy update when YOU want to
  checker = { enabled = false },
})
