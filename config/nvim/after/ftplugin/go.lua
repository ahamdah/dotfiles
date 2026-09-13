-- =============================================================================
-- after/ftplugin/go.lua — settings & shortcuts that load ONLY in Go files
-- =============================================================================
-- Files under after/ftplugin/<filetype>.lua are run by Neovim every time you
-- open a buffer of that filetype. Perfect home for language-specific keymaps:
-- they're buffer-local, so `<leader>gr` means "go run" in Go files and stays
-- free everywhere else.
--
-- The `go …` shortcuts below all live under <leader>g ("Go"):
--   <leader>gr  run the current package (go run .)
--   <leader>gb  build everything      (go build ./...)
--   <leader>gt  test the whole module (go test ./...)
--   <leader>gT  test with coverage    (go test -cover ./...)
--   <leader>gm  tidy modules          (go mod tidy)
-- Output opens in a terminal split at the bottom. Press `i` to scroll/interact,
-- or just read it and close the split with <leader>gq (or :q in that window).

-- Run a shell command in a bottom terminal split, from THIS file's directory
-- (so `go run .` builds the package the file belongs to, not your cwd).
local function go_task(cmd)
  vim.cmd("write") -- save first so we run the latest code
  local dir = vim.fn.expand("%:p:h")
  -- botright = full-width split at the very bottom; resize keeps it compact
  vim.cmd("botright 15split")
  vim.cmd("terminal cd " .. vim.fn.fnameescape(dir) .. " && " .. cmd)
  vim.cmd("startinsert") -- drop into the terminal so you can see live output
end

local function map(keys, fn, desc)
  vim.keymap.set("n", keys, fn, { buffer = true, desc = "Go: " .. desc })
end

map("<leader>gr", function() go_task("go run .") end, "Run package")
map("<leader>gb", function() go_task("go build ./...") end, "Build all")
map("<leader>gt", function() go_task("go test ./...") end, "Test all")
map("<leader>gT", function() go_task("go test -cover ./...") end, "Test w/ coverage")
map("<leader>gm", function() go_task("go mod tidy") end, "go mod tidy")
map("<leader>gq", "<cmd>close<cr>", "Close output split")

-- Inside any terminal, press Esc twice to get back to normal mode (so you can
-- scroll the output or close the window). Global — the terminal split is its
-- own buffer, not this Go file's buffer. Guarded so we only define it once.
if not vim.g._term_esc_map then
  vim.g._term_esc_map = true
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: normal mode" })
end
