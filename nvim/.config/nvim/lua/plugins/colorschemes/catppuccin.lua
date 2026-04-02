local utils = require "utils.pack"

local config = function()
  require("catppuccin").setup {
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
  }
end

utils.add({ src = "https://github.com/catppuccin/nvim", name = "catppuccin" }, config)
