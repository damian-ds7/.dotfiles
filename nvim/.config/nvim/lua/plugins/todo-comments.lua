return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTelescope", "TodoTrouble" },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {
    keywords = {
      TODO = { alt = { "todo", "unimplemented" } },
    },
    highlight = {
      pattern = {
        [[.*<(KEYWORDS)\s*:]],
        [[.*<(KEYWORDS)\s*!\(]],
      },
      comments_only = false,
    },
    search = {
      pattern = [[\b(KEYWORDS)(:|!\()]],
    },
  },
  keys = {
    {
      "]t",
      function() require("todo-comments").jump_next() end,
      desc = "Next todo comment",
    },
    {
      "[t",
      function() require("todo-comments").jump_prev() end,
      desc = "Previous todo comment",
    },
    { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
  },
}
