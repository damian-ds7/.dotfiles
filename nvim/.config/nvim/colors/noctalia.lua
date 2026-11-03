-- Base16 colorscheme from the noctalia-generated palette (themes/current-theme.lua)

local path = require("utils.colorscheme").palette_path()
if not path then error "noctalia: no generated palette is linked as themes/current-theme.lua" end

local palette = dofile(path)

vim.cmd.highlight "clear"
vim.o.background = palette.mode
require("mini.base16").setup { palette = palette.base16 }
vim.g.colors_name = "noctalia"

local function clear_bg(group, hl)
  hl = hl or vim.api.nvim_get_hl(0, { name = group, link = false })
  hl.bg = nil
  vim.api.nvim_set_hl(0, group, hl)
end

-- mini.base16 gives signs (GitSigns*, DiagnosticSign*, ...) the sign column's background,
-- some through links (DiagnosticSign* -> DiagnosticFloating*), so resolve them.
-- Signature help is a floating window and keeps its background.
local sign_bg = vim.api.nvim_get_hl(0, { name = "SignColumn" }).bg
for group in pairs(vim.api.nvim_get_hl(0, {})) do
  if group:find "Sign" and not group:find "Signature" then
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    if hl.bg and hl.bg == sign_bg then clear_bg(group, hl) end
  end
end

-- Transparent background, like the catppuccin and vague setups
for _, group in ipairs {
  "Normal",
  "NormalNC",
  "SignColumn",
  "FoldColumn",
  "LineNr",
  "LineNrAbove",
  "LineNrBelow",
  "EndOfBuffer",
  "StatusLine",
  "StatusLineNC",
} do
  clear_bg(group)
end
