local M = {}

local helper = vim.fn.expand "~/.local/bin/project-cache-helper"
local projects_dir = vim.env.PROJECTS_DIR or (vim.env.HOME .. "/Projects")

local function update_mru(full_path) vim.system { helper, "select", full_path } end

local function get_items()
  local result = vim.system({ helper, "list" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout or result.stdout == "" then return {} end
  local items = {}
  local i = 0
  for line in result.stdout:gmatch "[^\n]+" do
    if line ~= "" then
      i = i + 1
      local display = line:gsub("^" .. projects_dir .. "/", "")
      table.insert(items, {
        idx = i,
        text = display,
        full_path = line,
        file = line,
      })
    end
  end
  return items
end

function M.pick()
  if vim.fn.executable(helper) ~= 1 then
    M.pick_fallback()
    return
  end

  local items = get_items()

  Snacks.picker {
    title = "Projects",
    items = items,
    format = function(item, _) return { { item.text } } end,
    confirm = function(picker, item)
      picker:close()
      update_mru(item.full_path)
      vim.cmd.cd(item.full_path)
      vim.schedule(function()
        local session = require "utils.session"
        session.reset()
        local restored = session.restore_session()
        if not restored then
          vim.cmd "silent! %bdelete!"
          session.write_session()
        end
      end)
    end,
  }
end

function M.pick_fallback()
  Snacks.picker.pick {
    finder = "recent_projects",
    format = "file",
    dev = { "~/Projects" },
    confirm = "load_session",
    patterns = { ".git", "package.json", "Makefile", "Cargo.toml" },
    recent = true,
    matcher = {
      frecency = true,
      sort_empty = true,
      cwd_bonus = false,
    },
    sort = { fields = { "score:desc", "idx" } },
  }
end

return M
