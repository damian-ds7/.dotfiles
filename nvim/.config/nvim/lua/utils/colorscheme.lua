-- Applies the colorscheme named in themes/current-theme and reapplies it on SIGUSR1

local M = {}

function M.get_colorscheme()
  local path = vim.fs.joinpath(vim.fn.stdpath "config", "themes", "current-theme")

  local colorscheme = vim.trim(vim.fn.readfile(path)[1])
  return colorscheme
end

function M.apply()
  local ok, err = pcall(function() vim.cmd.colorscheme(M.get_colorscheme()) end)
  if not ok then vim.notify("Failed to apply theme: " .. err, vim.log.levels.WARN) end
end

function M.setup()
  M.apply()

  vim.api.nvim_create_autocmd("Signal", {
    desc = "Reload theme",
    group = vim.api.nvim_create_augroup("theme-reload", { clear = true }),
    pattern = "SIGUSR1",
    nested = true,
    callback = function() M.apply() end,
  })
end

return M
