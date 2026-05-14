vim.keymap.set(
  "n",
  "]t",
  function() require("todo-comments").jump_next() end,
  { desc = "Next todo comment" }
)

vim.keymap.set(
  "n",
  "[t",
  function() require("todo-comments").jump_prev() end,
  { desc = "Previous todo comment" }
)

vim.keymap.set(
  "n",
  "<leader>st",
  function() Snacks.picker.todo_comments() end,
  { desc = "Todo" }
)
vim.keymap.set(
  "n",
  "<leader>sT",
  function() Snacks.picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } } end,
  { desc = "Todo/Fix/Fixme" }
)

return plugin {
  src = "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
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
}
