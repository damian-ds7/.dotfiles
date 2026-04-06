local utils = require "utils.pack"

utils.ensure { src = utils.gh "kevinhwang91/promise-async", name = "promise" }

utils.add(utils.gh "kevinhwang91/nvim-ufo", function()
  vim.cmd.packadd "promise"
  vim.keymap.set("n", "zR", require("ufo").openAllFolds)
  vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
  require("ufo").setup()
end, "event:BufReadPost,BufWritePost,BufNewFile")
