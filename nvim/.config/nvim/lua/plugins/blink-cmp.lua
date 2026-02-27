return {
  {
    "saghen/blink.compat",
    optional = true,
    opts = {},
    version = "2.*",
  },
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      appearance = {
        nerd_font_variant = "mono",
        kind_icons = require("utils.icons").kinds,
      },

      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          border = "rounded",
          scrollbar = false,
          winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:BlinkCmpMenuSelection,Search:None",
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "label", "label_description", gap = 2 },
              { "kind_icon", "kind", gap = 2 },
            },
          },
        },
        documentation = {
          auto_show = true,
          treesitter_highlighting = true,
          auto_show_delay_ms = 500,
          window = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:BlinkCmpDocCursorLine,Search:None,BlinkCmpDocSeparator:Normal",
          },
        },
        ghost_text = {
          enabled = true,
        },
      },

      -- signature = { enabled = true },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          menu = {
            auto_show = false,
          },
          ghost_text = { enabled = true },
        },
      },
    },
  },
}
