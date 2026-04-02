local utils = require "utils.pack"
local registry = require "core.lang_reg"

utils.ensure "https://github.com/rcarriga/nvim-dap-ui"
utils.ensure "https://github.com/nvim-neotest/nvim-nio"
utils.ensure "https://github.com/theHamsta/nvim-dap-virtual-text"
utils.ensure "https://github.com/jay-babu/mason-nvim-dap.nvim"

utils.add("https://github.com/mfussenegger/nvim-dap", function()
  vim.cmd.packadd "nvim-nio"
  vim.cmd.packadd "nvim-dap-ui"
  vim.cmd.packadd "nvim-dap-virtual-text"
  vim.cmd.packadd "plenary.nvim"

  local dap = require "dap"
  local dapui = require "dapui"
  local icons = require "utils.icons"
  local reg_data = registry.get_all().dap

  dapui.setup {}
  require("nvim-dap-virtual-text").setup {}

  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open {} end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close {} end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close {} end

  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
  for name, sign in pairs(icons.dap or {}) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define("Dap" .. name, {
      text = sign[1],
      texthl = sign[2] or "DiagnosticInfo",
      linehl = sign[3],
      numhl = sign[3],
    })
  end

  dap.adapters = vim.tbl_deep_extend("force", dap.adapters, reg_data.adapters or {})
  dap.configurations = vim.tbl_deep_extend("force", dap.configurations, reg_data.configurations or {})

  local vscode = require "dap.ext.vscode"
  local json = require "plenary.json"
  vscode.json_decode = function(str) return vim.json.decode(json.json_strip_comments(str)) end
end, "later")

utils.add("https://github.com/jay-babu/mason-nvim-dap.nvim", function()
  vim.cmd.packadd "mason.nvim"
  require("mason-nvim-dap").setup {
    automatic_installation = true,
    ensure_installed = registry.get_all().tools or {},
    handlers = {},
  }
end, "event:BufReadPost,BufWritePost,BufNewFile")

local dap = function() return require "dap" end
local dapui = function() return require "dapui" end
local widgets = function() return require "dap.ui.widgets" end

vim.keymap.set("n", "<F5>", function() dap().continue() end, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", function() dap().step_over() end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", function() dap().step_into() end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", function() dap().step_out() end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<S-F5>", function() dap().terminate() end, { desc = "Debug: Stop" })
vim.keymap.set("n", "<C-S-F5>", function() dap().restart() end, { desc = "Debug: Restart" })

vim.keymap.set("n", "<F9>", function() dap().toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>db", function() dap().toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set(
  "n",
  "<leader>dB",
  function() dap().set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
  { desc = "Breakpoint Condition" }
)

vim.keymap.set("n", "<leader>dc", function() dap().continue() end, { desc = "Run/Continue" })
vim.keymap.set("n", "<leader>dC", function() dap().run_to_cursor() end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>dg", function() dap().goto_() end, { desc = "Go to Line (No Execute)" })
vim.keymap.set("n", "<leader>di", function() dap().step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function() dap().step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dO", function() dap().step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dj", function() dap().down() end, { desc = "Down" })
vim.keymap.set("n", "<leader>dk", function() dap().up() end, { desc = "Up" })

vim.keymap.set("n", "<leader>dl", function() dap().run_last() end, { desc = "Run Last" })
vim.keymap.set("n", "<leader>dP", function() dap().pause() end, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", function() dap().repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", function() dap().session() end, { desc = "Session" })
vim.keymap.set("n", "<leader>dt", function() dap().terminate() end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dw", function() widgets().hover() end, { desc = "Widgets" })
vim.keymap.set("n", "<leader>du", function() dapui().toggle {} end, { desc = "Dap UI" })
vim.keymap.set({ "n", "x" }, "<leader>de", function() dapui().eval() end, { desc = "Eval" })

local function get_args(config)
  local args = vim.fn.input "Args: "
  return vim.split(args, " ")
end

vim.keymap.set("n", "<leader>da", function() dap().continue { before = get_args } end, { desc = "Run with Args" })
