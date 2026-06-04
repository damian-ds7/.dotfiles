local registry = require "core.lang_reg"

local dap = function() return require "dap" end
local dapui = function() return require "dapui" end
local widgets = function() return require "dap.ui.widgets" end

local function get_args(config)
  local args = vim.fn.input "Args: "
  return vim.split(args, " ")
end

return {
  plugin {
    src = "mfussenegger/nvim-dap",
    name = "dap",
    lazy = true,
    dependencies = {
      { src = "rcarriga/nvim-dap-ui", name = "dapui" },
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local nvim_dap = require "dap"
      local nvim_dapui = require "dapui"
      local icons = require "utils.icons"
      local reg_data = registry.get_all().dap

      nvim_dapui.setup {}
      require("nvim-dap-virtual-text").setup {}

      nvim_dap.listeners.after.event_initialized["dapui_config"] = function()
        nvim_dapui.open {}
      end
      nvim_dap.listeners.before.event_terminated["dapui_config"] = function()
        nvim_dapui.close {}
      end
      nvim_dap.listeners.before.event_exited["dapui_config"] = function()
        nvim_dapui.close {}
      end

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

      nvim_dap.adapters =
        vim.tbl_deep_extend("force", nvim_dap.adapters, reg_data.adapters or {})
      nvim_dap.configurations = vim.tbl_deep_extend(
        "force",
        nvim_dap.configurations,
        reg_data.configurations or {}
      )

      local vscode = require "dap.ext.vscode"
      local json = require "plenary.json"
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
    keys = {
      { "n", "<F5>", function() dap().continue() end, desc = "Debug: Continue" },
      { "n", "<F10>", function() dap().step_over() end, desc = "Debug: Step Over" },
      { "n", "<F11>", function() dap().step_into() end, desc = "Debug: Step Into" },
      { "n", "<F12>", function() dap().step_out() end, desc = "Debug: Step Out" },
      { "n", "<S-F5>", function() dap().terminate() end, desc = "Debug: Stop" },
      { "n", "<C-S-F5>", function() dap().restart() end, desc = "Debug: Restart" },
      {
        "n",
        "<F9>",
        function() dap().toggle_breakpoint() end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "n",
        "<leader>db",
        function() dap().toggle_breakpoint() end,
        desc = "Toggle Breakpoint",
      },
      {
        "n",
        "<leader>dB",
        function() dap().set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
        desc = "Breakpoint Condition",
      },
      { "n", "<leader>dc", function() dap().continue() end, desc = "Run/Continue" },
      {
        "n",
        "<leader>dC",
        function() dap().run_to_cursor() end,
        desc = "Run to Cursor",
      },
      {
        "n",
        "<leader>dg",
        function() dap().goto_() end,
        desc = "Go to Line (No Execute)",
      },
      { "n", "<leader>di", function() dap().step_into() end, desc = "Step Into" },
      { "n", "<leader>do", function() dap().step_out() end, desc = "Step Out" },
      { "n", "<leader>dO", function() dap().step_over() end, desc = "Step Over" },
      { "n", "<leader>dj", function() dap().down() end, desc = "Down" },
      { "n", "<leader>dk", function() dap().up() end, desc = "Up" },
      { "n", "<leader>dl", function() dap().run_last() end, desc = "Run Last" },
      { "n", "<leader>dP", function() dap().pause() end, desc = "Pause" },
      { "n", "<leader>dr", function() dap().repl.toggle() end, desc = "Toggle REPL" },
      { "n", "<leader>ds", function() dap().session() end, desc = "Session" },
      { "n", "<leader>dt", function() dap().terminate() end, desc = "Terminate" },
      { "n", "<leader>dw", function() widgets().hover() end, desc = "Widgets" },
      { "n", "<leader>du", function() dapui().toggle {} end, desc = "Dap UI" },
      { { "n", "x" }, "<leader>de", function() dapui().eval() end, desc = "Eval" },
      {
        "n",
        "<leader>da",
        function() dap().continue { before = get_args } end,
        desc = "Run with Args",
      },
    },
  },
  plugin {
    src = "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      { src = "mfussenegger/nvim-dap", name = "dap" },
    },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      require("mason-nvim-dap").setup {
        automatic_installation = true,
        ensure_installed = registry.get_all().tools or {},
        handlers = {},
      }
    end,
  },
}
