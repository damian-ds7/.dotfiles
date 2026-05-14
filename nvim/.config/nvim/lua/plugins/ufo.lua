return plugin {
  src = "kevinhwang91/nvim-ufo",
  dependencies = { { src = "kevinhwang91/promise-async", name = "promise" } },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  config = function(opts)
    vim.keymap.set("n", "zR", require("ufo").openAllFolds)
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    require("ufo").setup(opts)
  end,
  opts = {},
}
