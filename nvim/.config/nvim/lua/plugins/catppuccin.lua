return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = function(_, opts)
    opts = opts or {}
    opts.transparent_background = true
    -- opts.float = {
    --   transparent = true,
    --   solid = false,
    -- }
    -- opts.custom_highlights = {
    --   SnackNormal = { link = "NormalFloat" },
    --   SnacksNormalNC = { link = "NormalFloat" },
    -- }
    return opts
  end,
}
