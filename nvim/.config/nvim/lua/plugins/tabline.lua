return plugin {
  src = "nvim-mini/mini.icons",
  lazy = true,
  config = function()
    local separator = { left = "", right = "" }

    local function hl_color(name, attr, fallback)
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      local val = hl[attr]
      return val and string.format("#%06x", val) or fallback
    end

    local function set_pill_highlights()
      local fill_bg = hl_color("TabLineFill", "bg", "NONE")
      local active_bg = hl_color("Pmenu", "bg", "#45475a")
      local inactive_bg = hl_color("CursorLine", "bg", "#313244")
      local active_fg = hl_color("Normal", "fg", "#cdd6f4")
      local inactive_fg = hl_color("Comment", "fg", "#6c7086")
      local modified_fg = hl_color("DiagnosticWarn", "fg", "#f9e2af")

      vim.api.nvim_set_hl(0, "PillTabFill", { bg = fill_bg })

      vim.api.nvim_set_hl(
        0,
        "PillTabActive",
        { bg = active_bg, fg = active_fg, bold = true }
      )
      vim.api.nvim_set_hl(
        0,
        "PillTabActiveModified",
        { bg = active_bg, fg = modified_fg, bold = true }
      )
      vim.api.nvim_set_hl(0, "PillTabActiveSep", { fg = active_bg, bg = fill_bg })

      vim.api.nvim_set_hl(0, "PillTabInactive", { bg = inactive_bg, fg = inactive_fg })
      vim.api.nvim_set_hl(0, "PillTabInactiveSep", { fg = inactive_bg, bg = fill_bg })
    end

    set_pill_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("pill-tabline-highlights", { clear = true }),
      callback = set_pill_highlights,
    })

    local function escape_tabline_text(text) return text:gsub("%%", "%%%%") end

    local function get_icon(filename)
      local ok, mini_icons = pcall(require, "mini.icons")
      if ok and mini_icons.get then
        local icon = select(1, mini_icons.get("file", filename))
        if icon and icon ~= "" then return icon .. " " end
      end
      return ""
    end

    local function get_tab_label(tab)
      local win = vim.api.nvim_tabpage_get_win(tab)
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      local filename = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
      local label = get_icon(filename) .. filename
      if vim.bo[buf].modified then label = label .. " ●" end
      return escape_tabline_text(label), vim.bo[buf].modified
    end

    _G.PillTablineGoToTab = function(tab)
      tab = tonumber(tab)
      if tab and vim.api.nvim_tabpage_is_valid(tab) then
        pcall(vim.api.nvim_set_current_tabpage, tab)
      end
    end

    _G.PillTabline = function()
      local parts = { "%#PillTabFill#%= " }
      local current = vim.api.nvim_get_current_tabpage()

      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local label, modified = get_tab_label(tab)
        local click = string.format("%%%d@v:lua.PillTablineGoToTab@", tab)
        local body_hl, sep_hl

        if tab == current then
          body_hl = modified and "PillTabActiveModified" or "PillTabActive"
          sep_hl = "PillTabActiveSep"
        else
          body_hl = "PillTabInactive"
          sep_hl = "PillTabInactiveSep"
        end

        table.insert(
          parts,
          string.format(
            "%s%%#%s#%s%%#%s# %s %%#%s#%s%%X%%#PillTabFill# ",
            click,
            sep_hl,
            separator.left,
            body_hl,
            label,
            sep_hl,
            separator.right
          )
        )
      end

      table.insert(parts, "%#PillTabFill#%=")
      return table.concat(parts)
    end

    local function update_showtabline()
      vim.o.showtabline = #vim.api.nvim_list_tabpages() > 1 and 2 or 0
    end

    update_showtabline()
    vim.api.nvim_create_autocmd({ "TabNew", "TabClosed", "TabEnter" }, {
      group = vim.api.nvim_create_augroup("pill-tabline-visibility", { clear = true }),
      callback = update_showtabline,
    })

    vim.o.tabline = "%!v:lua.PillTabline()"
  end,
}
