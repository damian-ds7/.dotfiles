local utils = require "utils.pack"

local config = function()
  require("rose-pine").setup {
    styles = { transparency = true },
    highlight_groups = {
      TelescopeSelection = { fg = "text", bg = "highlight_med", inherit = false },
      TelescopeSelectionCaret = { fg = "rose", bg = "highlight_med" },
      StatusLineTerm = { fg = "base", bg = "base" },
    },
  }
end

utils.add({ src = utils.gh "rose-pine/neovim", name = "rose-pine" }, config)
