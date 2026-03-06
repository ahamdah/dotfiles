-- =============================================================================
-- options.lua — Core Neovim settings
-- =============================================================================
local opt = vim.opt

-- ── UI ────────────────────────────────────────────────────────────────────────
opt.number          = true       -- show line numbers
opt.relativenumber  = true       -- relative numbers for easy jumps
opt.signcolumn      = "yes"      -- always show sign column (no jitter)
opt.cursorline      = true       -- highlight current line
opt.scrolloff       = 8          -- keep 8 lines above/below cursor
opt.sidescrolloff   = 8
opt.wrap            = false      -- no line wrapping
opt.linebreak       = true       -- break at word boundary if wrap is on
opt.termguicolors   = true       -- true color support
opt.showmode        = false      -- mode shown in statusline instead
opt.laststatus      = 3          -- global statusline

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.expandtab       = true       -- spaces not tabs
opt.tabstop         = 2
opt.shiftwidth      = 2
opt.softtabstop     = 2
opt.smartindent     = true
opt.autoindent      = true

-- ── Search ────────────────────────────────────────────────────────────────────
opt.hlsearch        = true
opt.incsearch       = true
opt.ignorecase      = true
opt.smartcase        = true      -- case-sensitive if uppercase used

-- ── Files & Buffers ───────────────────────────────────────────────────────────
opt.encoding        = "utf-8"
opt.fileencoding    = "utf-8"
opt.hidden          = true       -- allow switching unsaved buffers
opt.undofile        = true       -- persistent undo
opt.undodir         = vim.fn.stdpath("data") .. "/undo"
opt.backup          = false
opt.swapfile        = false
opt.autoread        = true       -- reload files changed outside nvim

-- ── Splits ────────────────────────────────────────────────────────────────────
opt.splitright      = true       -- vertical splits go right
opt.splitbelow      = true       -- horizontal splits go down

-- ── Completion & Menus ────────────────────────────────────────────────────────
opt.completeopt     = { "menu", "menuone", "noselect" }
opt.pumheight       = 10         -- max items in popup menu
opt.wildmenu        = true
opt.wildmode        = "longest:full,full"

-- ── Performance ───────────────────────────────────────────────────────────────
opt.updatetime      = 200        -- faster CursorHold events (for LSP)
opt.timeoutlen      = 300        -- faster leader key timeout

-- ── Clipboard ─────────────────────────────────────────────────────────────────
opt.clipboard       = "unnamedplus"   -- use system clipboard

-- ── Folding ───────────────────────────────────────────────────────────────────
opt.foldmethod      = "expr"
opt.foldexpr        = "nvim_treesitter#foldexpr()"
opt.foldenable      = false      -- don't auto-fold on open
opt.foldlevel       = 99

-- ── Misc ──────────────────────────────────────────────────────────────────────
opt.mouse           = "a"        -- enable mouse in all modes
opt.conceallevel    = 2          -- hide markdown markers
opt.list            = true
opt.listchars       = { tab = "» ", trail = "·", nbsp = "␣" }
