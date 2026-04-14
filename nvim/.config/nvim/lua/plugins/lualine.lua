local icons = require "utils.icons"
local utils = require "utils.pack"

utils.add(utils.gh "nvim-lualine/lualine.nvim", function()
  require("lualine").setup {
    options = {
      theme = "auto",
      component_separators = "",
      section_separators = { left = "", right = "" },
      globalstatus = true,
      icons_enabled = true,
      disabled_filetypes = {},
    },
    sections = {
      lualine_a = { { "mode", icon = "", separator = { left = "" }, right_padding = 2 } },
      lualine_b = {
        {
          "branch",
          fmt = function(str)
            if vim.api.nvim_strwidth(str) > 40 then return ("%s…"):format(str:sub(1, 39)) end
            return str
          end,
        },
      },
      lualine_c = {
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.error,
            warn = icons.diagnostics.warn,
            info = icons.diagnostics.info,
            hint = icons.diagnostics.hint,
          },
        },
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        {
          "filename",
          path = 1,
          symbols = { modified = " ●", readonly = " ", unnamed = "", separator = "" },
        },
      },
      lualine_x = {
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = function()
            local hl = vim.api.nvim_get_hl(0, { name = "Statement" })
            return { fg = string.format("#%06x", hl.fg or 0) }
          end,
        },
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = function()
            local hl = vim.api.nvim_get_hl(0, { name = "Constant" })
            return { fg = string.format("#%06x", hl.fg or 0), gui = "bold" }
          end,
        },
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        },
        {
          "diff",
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
      lualine_z = {
        {
          function() return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end,
          color = { gui = "bold" },
          separator = { right = "" },
        },
      },
    },
  }
end, "later")
