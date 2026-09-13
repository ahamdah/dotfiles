-- =============================================================================
-- Telescope: fuzzy finder for everything (files, text, symbols, ...)
-- =============================================================================
-- The fastest way to move around a codebase. Start typing and it filters live.
-- Uses ripgrep (rg) and fd, which you already have installed.
--
-- Keys (all under <leader>f… "find"):
--   <leader>ff  find files      <leader>fg  live grep (search all text)
--   <leader>fb  open buffers     <leader>fh  search help
--   <leader>fs  document symbols  <leader>fw  grep word under cursor
-- Inside a picker: <C-n>/<C-p> move · <Enter> open · <C-x>/<C-v> split · <Esc> close

-- ── "Search Everywhere" (IntelliJ double-Shift) ─────────────────────────────
-- One picker that merges THREE sources into a single result list:
--   (a) project FILES        — from `fd` (loaded once when the picker opens)
--   (b) code SYMBOLS         — functions/types/methods, live from gopls
--   (c) TEXT inside files    — live ripgrep of file contents
-- Type 2+ characters and all three update together. Telescope has no built-in
-- picker that merges sources, so we build one here. (Defined as a plain local
-- function so lazy.nvim can reference it from `keys`; the `require`s run only
-- when you actually open it.)
local function search_everywhere()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local entry_display = require("telescope.pickers.entry_display")

  -- Gather every project file once (fd respects .gitignore; rg is the fallback).
  local file_cmd
  if vim.fn.executable("fd") == 1 then
    file_cmd = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
  else
    file_cmd = { "rg", "--files", "--hidden", "--glob", "!.git" }
  end

  -- Two columns: a kind icon, then name, then the location on the right.
  local displayer = entry_display.create({
    separator = "  ",
    items = { { width = 2 }, { width = 48 }, { remaining = true } },
  })

  -- LSP SymbolKind number → a short nerd-font glyph
  local kind_glyph = {
    [5] = "󰠲",  -- Class
    [6] = "󰆧",  -- Method
    [8] = "󰜢",  -- Field
    [11] = "",  -- Interface
    [12] = "󰊕",  -- Function
    [13] = "󰀫",  -- Variable
    [23] = "󰙅",  -- Struct
  }

  local function file_entry(path)
    local rel = vim.fn.fnamemodify(path, ":.")
    return {
      value = path,
      ordinal = rel,          -- what the fuzzy sorter matches against
      filename = path,
      display = function()
        return displayer({ { "", "TelescopeResultsComment" }, rel, "" })
      end,
    }
  end

  local function symbol_entry(sym)
    local path = vim.uri_to_fname(sym.location.uri)
    local rel = vim.fn.fnamemodify(path, ":.")
    local lnum = sym.location.range.start.line + 1
    local col = sym.location.range.start.character + 1
    return {
      value = sym,
      ordinal = sym.name,
      filename = path,
      lnum = lnum,
      col = col,
      display = function()
        return displayer({
          { kind_glyph[sym.kind] or "󰎁", "TelescopeResultsFunction" },
          sym.name,
          rel .. ":" .. lnum,
        })
      end,
    }
  end

  -- A match found INSIDE a file's text (one ripgrep line: file:lnum:col:text).
  local function grep_entry(path, lnum, col, text)
    local rel = vim.fn.fnamemodify(path, ":.")
    return {
      value = path .. ":" .. lnum,
      ordinal = text,          -- match the prompt against the line's content
      filename = path,
      lnum = tonumber(lnum),
      col = tonumber(col),
      display = function()
        return displayer({
          { "", "TelescopeResultsNumber" }, -- magnifier = "text match"
          vim.trim(text):sub(1, 48),
          rel .. ":" .. lnum,
        })
      end,
    }
  end

  -- Build the file entries a single time, then reuse them on every keystroke.
  local file_entries = {}
  for _, f in ipairs(vim.fn.systemlist(file_cmd)) do
    file_entries[#file_entries + 1] = file_entry(f)
  end

  local finder = finders.new_dynamic({
    entry_maker = function(e) return e end, -- fn already returns finished entries
    fn = function(prompt)
      local results = {}
      -- Always include the files; the sorter filters/ranks them by the prompt.
      for _, e in ipairs(file_entries) do
        results[#results + 1] = e
      end
      -- Once you've typed a couple characters, also search symbols and text.
      if prompt and #prompt >= 2 then
        -- (b) matching SYMBOLS from gopls (functions, types, methods)
        for _, client in ipairs(vim.lsp.get_clients()) do
          if client:supports_method("workspace/symbol") then
            local r = client:request_sync("workspace/symbol", { query = prompt }, 400, 0)
            if r and r.result then
              for _, sym in ipairs(r.result) do
                results[#results + 1] = symbol_entry(sym)
              end
            end
          end
        end
        -- (c) matching TEXT inside files (ripgrep), capped so it stays snappy
        local rg = vim.fn.systemlist({
          "rg", "--vimgrep", "--smart-case", "--fixed-strings",
          "--max-columns=300", "--color=never", prompt,
        })
        for i, line in ipairs(rg) do
          if i > 200 then break end -- don't flood the list on common words
          local f, l, c, t = line:match("^(.-):(%d+):(%d+):(.*)$")
          if f then
            results[#results + 1] = grep_entry(f, l, c, t)
          end
        end
      end
      return results
    end,
  })

  pickers.new({}, {
    prompt_title = "Search Everywhere — files + symbols",
    finder = finder,
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
  }):find()
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { -- native C sorter: makes filtering noticeably faster
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function() return vim.fn.executable("make") == 1 end,
    },
  },
  cmd = "Telescope",
  keys = {
    -- ── "Search Everywhere" — files + symbols in one list ───────────────────
    -- Double-tap Left Shift (Karabiner→Cmd+'→iTerm→<M-'>) OR double-tap the
    -- leader key (Space Space) opens the combined IntelliJ-style picker.
    { "<M-'>", search_everywhere, mode = { "n", "i" }, desc = "Search Everywhere (double-Shift)" },
    { "<leader><leader>", search_everywhere, desc = "Search Everywhere (files + symbols)" },
    { "<leader>S", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search project symbols" },

    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
    { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics list" },
  },
  config = function()
    require("telescope").setup({})
    pcall(require("telescope").load_extension, "fzf")
  end,
}
