return {
  {
    "folke/trouble.nvim",
    -- cmd = { "Trouble" },
    -- opts = {
    --   modes = {
    --     lsp = {
    --       win = { position = "right" },
    --     },
    --   },
    -- },
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle win.size=35 focus=true<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle focus=true win.size=35 filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      { "<leader>cs", "<cmd>Trouble symbols toggle win.size=35 focus=true<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>cS",
        "<cmd>Trouble lsp toggle win.size=35 focus=true<cr>",
        desc = "LSP references/definitions/... (Trouble)",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle focus=true<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle focus=true<cr>", desc = "Quickfix List (Trouble)" },
      -- {
      --   "[q",
      --   function()
      --     if require("trouble").is_open() then
      --       require("trouble").prev({ skip_groups = true, jump = true })
      --     else
      --       local ok, err = pcall(vim.cmd.cprev)
      --       if not ok then
      --         vim.notify(err, vim.log.levels.ERROR)
      --       end
      --     end
      --   end,
      --   desc = "Previous Trouble/Quickfix Item",
      -- },
      -- {
      --   "]q",
      --   function()
      --     if require("trouble").is_open() then
      --       require("trouble").next({ skip_groups = true, jump = true })
      --     else
      --       local ok, err = pcall(vim.cmd.cnext)
      --       if not ok then
      --         vim.notify(err, vim.log.levels.ERROR)
      --       end
      --     end
      --   end,
      --   desc = "Next Trouble/Quickfix Item",
      -- },
    },
  },
}
