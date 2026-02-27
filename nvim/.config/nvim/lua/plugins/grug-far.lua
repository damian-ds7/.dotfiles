return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = {
    headerMaxWidth = 80,
    engines = {
      ripgrep = { defaults = { flags = "--smart-case --multiline" } },
    },
  },
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require "grug-far"
        local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        }
      end,
      mode = { "n", "x" },
      desc = "Search and Replace",
    },
  },
}
