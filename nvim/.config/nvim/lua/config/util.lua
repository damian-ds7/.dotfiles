local M = {}

function M.get_colorscheme()
  local path = vim.fn.expand("~/.config/themes/current/nvim.conf")
  local colorscheme = vim.trim(vim.fn.readfile(path)[1])
  return colorscheme
end

return M
