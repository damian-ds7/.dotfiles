local map = vim.keymap.set

map(
  "n",
  "gp",
  function() require("lspeek").peek_definition() end,
  { desc = "Peek Definition (lspeek)" }
)
map(
  "n",
  "<leader>cp",
  function() require("lspeek").peek_definition() end,
  { desc = "Peek Definition (lspeek)" }
)

map(
  "n",
  "gP",
  function() require("lspeek").peek_type_definition() end,
  { desc = "Peek Type Definition (lspeek)" }
)
map(
  "n",
  "<leader>cP",
  function() require("lspeek").peek_type_definition() end,
  { desc = "Peek Type Definition (lspeek)" }
)

return plugin {
  src = "r4ppz/lspeek.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {
    window = {
      width = 70,
      height = 15,
      border = "rounded",
    },
  },
}
