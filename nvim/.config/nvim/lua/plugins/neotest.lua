return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace "neotest"
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic) return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "") end,
        },
      }, neotest_ns)

      require("neotest").setup {
        adapters = {
          require "rustaceanvim.neotest",
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          enabled = true,
          open = true,
        },
        consumers = {
          notify = function(client)
            client.listeners.results = function(_, results, partial)
              if partial then return end

              local total = 0
              local passed = 0
              for _, r in pairs(results) do
                total = total + 1
                if r.status == "passed" then passed = passed + 1 end
              end

              vim.notify(passed .. "/" .. total .. " tests passed.")
            end
          end,
        },
      }
    end,
    keys = {
      { "<leader>t", "", desc = "+test" },
      { "<leader>ta", function() require("neotest").run.attach() end, desc = "Attach to Test (Neotest)" },
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run File (Neotest)" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
      { "<leader>to", function() require("neotest").output.open { enter = true, auto_close = true } end, desc = "Show Output (Neotest)" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand "%") end, desc = "Toggle Watch (Neotest)" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      { "<leader>td", function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug Nearest" },
    },
  },
}
