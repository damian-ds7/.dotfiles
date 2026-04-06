local utils = require "utils.pack"

local config = function()
  require("which-key").setup {
    preset = "helix",
    defaults = {},
    spec = {
      {
        mode = { "n", "x" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>a", group = "ai" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "z", group = "fold" },
        { "gz", group = "surround" },
        {
          "<leader>b",
          group = "buffer",
          expand = function() return require("which-key.extras").expand.buf() end,
        },
        {
          "<leader>w",
          group = "windows",
          proxy = "<c-w>",
          expand = function() return require("which-key.extras").expand.win() end,
        },
        { "gx", desc = "Open with system app" },
        {
          "<leader>?",
          function() require("which-key").show { global = false } end,
          desc = "Buffer Keymaps (which-key)",
        },
      },
    },
  }
end

utils.add(utils.gh "folke/which-key.nvim", config, "later")
