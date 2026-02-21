return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>Y",
      "<cmd>Yazi cwd<cr>",
      desc = "Yazi (cwd)",
    },
    {
      "<leader>y",
      "<cmd>Yazi toggle<cr>",
      desc = "Yazi (resume)",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
}
