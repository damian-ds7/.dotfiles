return plugin {
  src = "rose-pine/neovim",
  name = "rose-pine",
  opts = {
    styles = { transparency = true },
    highlight_groups = {
      TelescopeSelection = { fg = "text", bg = "highlight_med", inherit = false },
      TelescopeSelectionCaret = { fg = "rose", bg = "highlight_med" },
      StatusLineTerm = { fg = "base", bg = "base" },
    },
  },
}
