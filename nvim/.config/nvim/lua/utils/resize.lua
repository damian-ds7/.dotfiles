-- Based on https://github.com/mrjones2014/smart-splits.nvim

local M = {}

local function is_floating() return vim.api.nvim_win_get_config(0).relative ~= "" end

local function resize_floating(direction, amount)
  local cfg = vim.api.nvim_win_get_config(0)
  if direction == "left" or direction == "right" then
    cfg.width = cfg.width + (direction == "right" and amount or -amount)
  else
    cfg.height = cfg.height + (direction == "down" and amount or -amount)
  end
  vim.api.nvim_win_set_config(0, cfg)
end

local function resize_dir_vertical(direction)
  local row = vim.api.nvim_win_get_position(0)[1]
  local is_top = row == 0
  if is_top then
    return direction == "down" and "+" or "-"
  else
    return direction == "down" and "-" or "+"
  end
end

local function resize_dir_horizontal(direction)
  local col = vim.api.nvim_win_get_position(0)[2]
  local is_left = col == 0
  if is_left then
    return direction == "right" and "+" or "-"
  else
    return direction == "right" and "-" or "+"
  end
end

function M.resize(direction, amount)
  amount = amount or 3

  if is_floating() then
    resize_floating(direction, amount)
    return
  end

  if direction == "up" or direction == "down" then
    local sign = resize_dir_vertical(direction)
    vim.cmd("resize " .. sign .. amount)
  else
    local sign = resize_dir_horizontal(direction)
    vim.cmd("vertical resize " .. sign .. amount)
  end
end

return M
