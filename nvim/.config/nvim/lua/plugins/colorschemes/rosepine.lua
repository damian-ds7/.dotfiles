return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = true,
  opts = {
    styles = { transparency = true },
    highlight_groups = {
      TelescopeSelection = { fg = "text", bg = "highlight_med", inherit = false },
      TelescopeSelectionCaret = { fg = "rose", bg = "highlight_med" },

      BufferLineSeparator = { fg = "base", bg = "base" },
      BufferLineSeparatorVisible = { fg = "base", bg = "base" },
      BufferLineSeparatorSelected = { fg = "base", bg = "base" },

      StatusLineTerm = { fg = "base", bg = "base" },

      -- BufferLineIndicatorSelected = { fg = "gold", bg = "NONE" },
    },
  },
}
