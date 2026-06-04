return plugin {
  src = "folke/todo-comments.nvim",
  lazy = true,
  opts = {
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
      "n",
      "]t",
      function() require("todo-comments").jump_next() end,
      desc = "Next todo comment",
    },
    {
      "n",
      "[t",
      function() require("todo-comments").jump_prev() end,
      desc = "Previous todo comment",
    },
    { "n", "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
    {
      "n",
      "<leader>sT",
      function() Snacks.picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } } end,
      desc = "Todo/Fix/Fixme",
    },
  },
}
