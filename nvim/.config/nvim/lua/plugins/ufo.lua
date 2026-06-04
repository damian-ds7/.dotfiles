return plugin {
  src = "kevinhwang91/nvim-ufo",
  dependencies = { { src = "kevinhwang91/promise-async", name = "promise" } },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  config = function(opts) require("ufo").setup(opts) end,
  opts = {},
  keys = {
    {
      "n",
      "zR",
      function() require("ufo").openAllFolds() end,
      desc = "Open All Folds",
    },
    {
      "n",
      "zM",
      function() require("ufo").closeAllFolds() end,
      desc = "Close All Folds",
    },
  },
}
