-- =============================================================================
-- Completion: the pop-up suggestion menu as you type (blink.cmp)
-- =============================================================================
-- blink.cmp is a fast, modern autocompletion engine. It pulls suggestions from
-- the language server (gopls), the current buffer, snippets, and file paths,
-- and ranks them as you type. This is the "IntelliSense" experience.
--
-- Default keys inside the menu:
--   <C-n>/<C-p> or arrows → move · <Tab> → accept · <C-e> → dismiss
--   <C-Space>             → open the menu / show docs
return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  version = "1.*", -- uses a prebuilt binary, so no Rust toolchain needed
  opts = {
    keymap = {
      preset = "default", -- <C-y> accept, <C-e> cancel, <C-n>/<C-p> navigate
      ["<Tab>"] = { "accept", "fallback" }, -- Tab also accepts the selection
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      -- Show the documentation window automatically next to the menu
      documentation = { auto_show = true, auto_show_delay_ms = 250 },
      menu = { border = "rounded" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    -- Fuzzy matching implemented in Rust for speed; downloads a prebuilt binary.
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true }, -- show function signature while typing args
  },
}
