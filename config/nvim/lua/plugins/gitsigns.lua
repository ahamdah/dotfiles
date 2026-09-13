-- =============================================================================
-- Gitsigns: see git changes right in the editor gutter
-- =============================================================================
-- Adds colored marks in the sign column: added / changed / removed lines,
-- relative to the last commit. Also lets you stage, preview and step through
-- hunks without leaving the buffer.
--
-- Keys:
--   ]h / [h        jump to next / previous change
--   <leader>hs     stage the hunk    <leader>hr  reset (undo) the hunk
--   <leader>hp     preview the hunk   <leader>hb  blame the current line
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Prev git hunk")
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>hd", gs.diffthis, "Diff this file")
    end,
  },
}
