return plugin {
  src = "folke/noice.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  lazy = true,
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  },
  keys = {
    { "n", "<leader>n", "", desc = "+noice" },
    {
      "c",
      "<S-Enter>",
      function() require("noice").redirect(vim.fn.getcmdline()) end,
      desc = "Redirect Cmdline",
    },
    {
      "n",
      "<leader>nl",
      function() require("noice").cmd "last" end,
      desc = "Noice Last Message",
    },
    {
      "n",
      "<leader>nh",
      function() require("noice").cmd "history" end,
      desc = "Noice History",
    },
    {
      "n",
      "<leader>na",
      function() require("noice").cmd "all" end,
      desc = "Noice All",
    },
    {
      "n",
      "<leader>nd",
      function() require("noice").cmd "dismiss" end,
      desc = "Noice Dismiss All",
    },
    {
      { "i", "n", "s" },
      "<c-f>",
      function()
        if not require("noice.lsp").scroll(4) then return "<c-f>" end
      end,
      silent = true,
      expr = true,
      desc = "Scroll Forward",
    },
    {
      { "i", "n", "s" },
      "<c-b>",
      function()
        if not require("noice.lsp").scroll(-4) then return "<c-b>" end
      end,
      silent = true,
      expr = true,
      desc = "Scroll Backward",
    },
  },
}
