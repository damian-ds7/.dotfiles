-- Applies the colorscheme named in themes/current-theme and reapplies it on SIGUSR1

local M = {}

local theme_dir = vim.fs.joinpath(vim.fn.stdpath "config", "themes")

---Path of the generated palette, if it is the current theme.
---@return string?
function M.palette_path()
  local path = vim.fs.joinpath(theme_dir, "current-theme.lua")
  if vim.uv.fs_stat(path) then return path end
end

---@return string
function M.get_colorscheme()
  if M.palette_path() then return "noctalia" end

  local path = vim.fs.joinpath(theme_dir, "current-theme")
  return vim.trim(vim.fn.readfile(path)[1])
end

function M.apply()
  local ok, err = pcall(function() vim.cmd.colorscheme(M.get_colorscheme()) end)
  if not ok then vim.notify("Failed to apply theme: " .. err, vim.log.levels.WARN) end
end

---Applies the current theme and reapplies it on SIGUSR1.
function M.setup()
  M.apply()

  vim.api.nvim_create_autocmd("Signal", {
    desc = "Reload theme",
    group = vim.api.nvim_create_augroup("theme-reload", { clear = true }),
    pattern = "SIGUSR1",
    -- Let ColorScheme autocmds (lualine, tabline, ...) fire from inside this one
    nested = true,
    callback = function() M.apply() end,
  })
end

return M
