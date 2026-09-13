-- =============================================================================
-- render-markdown.nvim: read markdown as markdown, right inside the buffer
-- =============================================================================
-- Treesitter already colors a .md file, but you still stare at the raw syntax:
-- `## Heading`, `**bold**`, `- [ ] todo`, pipe-tables that don't line up. This
-- plugin draws the rendered version over the text — headings get a colored
-- background, bullets become real dots, tables get proper borders, checkboxes
-- become boxes, code blocks get a tinted background.
--
-- It's a *display* layer, not a preview window: the line under your cursor
-- always drops back to raw markdown so you can edit it normally.
--
-- Keys:
--   <leader>m   toggle rendering off/on (handy when you want to see raw syntax)
--
-- Needs a Nerd Font for the icons — the iTerm2 profile in config/ already
-- uses one. For a full-screen read outside the editor, use `md file.md`
-- (the glow alias in shell/aliases.zsh).
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- supplies the markdown parse tree
    "nvim-tree/nvim-web-devicons",     -- language icons on fenced code blocks
  },
  ft = { "markdown" }, -- only loads once you actually open a markdown file
  opts = {
    -- Render everywhere except while you're typing, so insert mode shows the
    -- raw text you're editing rather than shifting under your cursor.
    render_modes = { "n", "v", "c" },
    heading = {
      -- Wide colored bars read better than the default sign-column icons
      width = "block",
      min_width = 60,
    },
    code = {
      width = "block",
      min_width = 60,
      language_pad = 1, -- breathing room before the `go` / `lua` label
    },
    -- Soft-wrap long prose lines in markdown only; the global default is
    -- nowrap, which makes paragraphs run off the right edge.
    win_options = {
      wrap = { default = false, rendered = true },
      linebreak = { default = false, rendered = true }, -- wrap at spaces, not mid-word
    },
  },
  keys = {
    { "<leader>m", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Markdown: toggle rendering" },
  },
}
