return {
  "rose-pine/neovim",
  name = "rose-pine",
  opts = function(_, opts)
    opts = opts or {}
    opts.styles = opts.styles or {}
    opts.styles.transparency = true

    opts.highlight_groups = {
      TelescopeSelection = { fg = "text", bg = "highlight_med", inherit = false },
      TelescopeSelectionCaret = { fg = "rose", bg = "highlight_med" },

      BufferLineSeparator = { fg = "base", bg = "base" },
      BufferLineSeparatorVisible = { fg = "base", bg = "base" },
      BufferLineSeparatorSelected = { fg = "base", bg = "base" },

      SnacksWinSeparator = { fg = "base", bg = "base" },

      BufferLineIndicatorSelected = { fg = "gold", bg = "NONE" },
    }

    return opts
  end,
}
