local utils = require "utils.pack"

local blink_config = function()
  vim.cmd.packadd "friendly-snippets"
  vim.cmd.packadd "blink.compat"
  require("blink.cmp").setup {
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
  }
end

utils.ensure(utils.gh "rafamadriz/friendly-snippets")
utils.ensure { src = utils.gh "saghen/blink.compat", version = vim.version.range "2.*" }

utils.add(
  { src = utils.gh "saghen/blink.cmp", version = vim.version.range "1.*" },
  blink_config
)
