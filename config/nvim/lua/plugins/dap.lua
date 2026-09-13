-- =============================================================================
-- Debugging: breakpoints, stepping, variable inspection (nvim-dap + delve)
-- =============================================================================
-- DAP = Debug Adapter Protocol, the debugging equivalent of LSP. nvim-dap is
-- the engine; nvim-dap-go wires it up to `dlv` (delve), Go's debugger, which
-- Mason installs for you. nvim-dap-ui draws the panels (variables, call stack,
-- breakpoints, watches).
--
-- Typical flow:
--   <leader>db  toggle a breakpoint on the current line
--   <leader>dc  start / continue (the UI opens automatically)
--   <leader>di  step into   <leader>do step over   <leader>dO step out
--   <leader>dt  debug the test function under the cursor
--   <leader>dx  stop the session and close the UI
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",  -- async library required by dap-ui
    "leoluz/nvim-dap-go",     -- Go-specific launch configs + `dlv` wiring
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug: start/continue" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: step out" },
    { "<leader>dt", function() require("dap-go").debug_test() end, desc = "Debug: nearest Go test" },
    { "<leader>dx", function() require("dap").terminate() require("dapui").close() end, desc = "Debug: stop" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("dap-go").setup() -- reads `dlv` from Mason's PATH automatically

    -- A red dot in the gutter marks a breakpoint
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual" })

    -- Open the debugging panels when a session starts, close them when it ends
    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
  end,
}
