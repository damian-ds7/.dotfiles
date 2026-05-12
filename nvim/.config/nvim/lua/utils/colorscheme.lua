local M = {}

function M.get_colorscheme()
  local path = vim.fs.joinpath(vim.fn.stdpath "config", "themes", "current-theme")

  local colorscheme = vim.trim(vim.fn.readfile(path)[1])
  return colorscheme
end

return M
