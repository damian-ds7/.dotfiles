local icons = require "utils.icons"

return plugin {
  src = "nvim-lualine/lualine.nvim",
  lazy = true,
  config = function(opts)
    local space = {
      function() return " " end,
      color = { bg = "NONE", fg = "NONE" },
      padding = 0,
    }

    local separator = { left = "", right = "" }

    local mode = {
      "mode",
      icon = "",
      separator = separator,
      right_padding = 2,
      fmt = function(str)
        local target = 8 -- length of "TERMINAL", the longest default mode string
        local pad = target - vim.api.nvim_strwidth(str)
        if pad <= 0 then return str end
        local left = math.floor(pad / 2)
        local right = pad - left
        return string.rep(" ", left) .. str .. string.rep(" ", right)
      end,
    }

    local function hl_color(name, attr, fallback)
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      local val = hl[attr]
      return val and string.format("#%06x", val) or fallback
    end

    -- neutral pill for widgets that carry their own colored icons (diff, diagnostics)
    local function pill_color() return { bg = hl_color("CursorLine", "bg", "NONE") } end

    -- relative luminance -> pick black/white text for contrast against a given bg
    local function contrast_fg(hex)
      local r = tonumber(hex:sub(2, 3), 16) / 255
      local g = tonumber(hex:sub(4, 5), 16) / 255
      local b = tonumber(hex:sub(6, 7), 16) / 255
      local function lin(c)
        return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
      end
      local luminance = 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
      return luminance > 0.5 and "#1e1e2e" or "#ffffff"
    end

    -- accent pill: bg pulled from a semantic highlight group's fg (so it tracks
    -- whatever colorscheme is active), text contrast computed from that bg color
    -- so it stays legible in both light and dark colorschemes
    local function accent_pill(hl_name, fallback)
      return function()
        local bg = hl_color(hl_name, "fg", fallback)
        return {
          bg = bg,
          fg = contrast_fg(bg),
          gui = "bold",
        }
      end
    end

    local branch = {
      "branch",
      separator = separator,
      color = accent_pill("String", "#a6e3a1"),
      fmt = function(str)
        if vim.api.nvim_strwidth(str) > 40 then
          return ("%s…"):format(str:sub(1, 39))
        end
        return str
      end,
    }

    local mini_icons_ok, mini_icons = pcall(require, "mini.icons")

    local function is_oil() return vim.bo.filetype == "oil" end

    -- oil:///home/user/project/  ->  /home/user/project/
    local function oil_dir()
      local ok, oil = pcall(require, "oil")
      ---@diagnostic disable-next-line: undefined-field
      if ok and oil.get_current_dir then
        ---@diagnostic disable-next-line: undefined-field
        local dir = oil.get_current_dir()
        if dir then return dir end
      end
      return vim.api.nvim_buf_get_name(0):gsub("^oil://", "")
    end

    local function shorten_path(path, max_len)
      max_len = max_len or 40
      local home = vim.env.HOME
      if home and path:sub(1, #home) == home then path = "~" .. path:sub(#home + 1) end
      if vim.api.nvim_strwidth(path) > max_len then
        path = "…" .. path:sub(-max_len)
      end
      return path
    end

    local function buf_tail()
      local name = vim.api.nvim_buf_get_name(0)
      return name == "" and "" or vim.fn.fnamemodify(name, ":t")
    end

    -- true for terminal (has a name like "12345:zsh") or any buffer with a real tail,
    -- and true for oil (handled specially even though its tail is "")
    local function has_filename() return is_oil() or buf_tail() ~= "" end

    local function file_icon()
      if not mini_icons_ok then return "" end
      if is_oil() then
        local icon = mini_icons.get("directory", oil_dir())
        return icon or ""
      end
      local icon = mini_icons.get("file", buf_tail())
      return icon or ""
    end

    local filename = {
      {
        file_icon,
        color = pill_color,
        separator = { left = "", right = "" },
        padding = { left = 1, right = 1 },
        cond = has_filename,
      },
      {
        "filename",
        path = 1,
        color = pill_color,
        separator = { left = "", right = "" },
        padding = { left = 0, right = 1 },
        symbols = {
          modified = "●",
          readonly = "",
          unnamed = "",
          separator = "",
        },
        fmt = function(str)
          if is_oil() then return "Oil: " .. shorten_path(oil_dir()) end
          if vim.bo.buftype == "terminal" then return vim.fn.fnamemodify(str, ":t") end
          return str
        end,
        cond = has_filename,
      },
    }

    local diff = {
      "diff",
      separator = separator,
      color = pill_color,
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
    }

    local macro = {
      ---@diagnostic disable-next-line: undefined-field
      function() return require("noice").api.status.mode.get() end,
      cond = function()
        ---@diagnostic disable-next-line: undefined-field
        return package.loaded["noice"] and require("noice").api.status.mode.has()
      end,
      color = function()
        local hl = vim.api.nvim_get_hl(0, { name = "Constant" })
        return { fg = string.format("#%06x", hl.fg or 0), gui = "bold" }
      end,
    }

    local diagnostics = {
      "diagnostics",
      symbols = {
        error = icons.diagnostics.Error,
        warn = icons.diagnostics.Warn,
        info = icons.diagnostics.Info,
        hint = icons.diagnostics.Hint,
      },
      separator = separator,
      color = pill_color,
      always_visible = true,
    }

    local deb = {
      function() return "  " .. require("dap").status() end,
      cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
    }

    local location = {
      {
        "progress",
        color = accent_pill("Type", "#f9e2af"),
        separator = { left = "", right = "" },
      },
      {
        "location",
        color = accent_pill("Type", "#f9e2af"),
        separator = { left = "", right = "" },
      },
    }

    local sections = {
      lualine_a = { mode },
      lualine_b = { space, branch },
      lualine_c = { space, filename[1], filename[2] },
      lualine_x = {
        macro,
        deb,
      },
      lualine_y = {
        diff,
        space,
        diagnostics,
      },
      lualine_z = {
        space,
        location[1],
        location[2],
      },
    }
    opts.sections = sections
    require("lualine").setup(opts)
  end,
  opts = {
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = " ", right = " " },
      globalstatus = true,
      icons_enabled = true,
      disabled_filetypes = {},
    },
  },
}
