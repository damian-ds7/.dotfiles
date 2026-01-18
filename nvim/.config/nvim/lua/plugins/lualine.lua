return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      component_separators = "",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
      lualine_b = {
        {
          "branch",
          fmt = function(str)
            if vim.api.nvim_strwidth(str) > 40 then
              return ("%s…"):format(str:sub(1, 39))
            end

            return str
          end,
        },
      },
      lualine_z = {
        {
          function()
            return " " .. os.date("%R")
          end,
          separator = { right = "" },
        },
      },
    },
  },
}
