return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = true,
  priority = 1000,
  opts = {
    transparent_background = true,
    custom_highlights = function(colors)
      return {
        BufferLineSeparator = { fg = colors.base, bg = colors.base },
        BufferLineSeparatorVisible = { fg = colors.base, bg = colors.base },
        BufferLineSeparatorSelected = { fg = colors.base, bg = colors.base },

        NoicePopup = { fg = colors.text, bg = colors.base },
        NoicePopupBorder = { fg = colors.text, bg = colors.base },
      }
    end,
  },
}
