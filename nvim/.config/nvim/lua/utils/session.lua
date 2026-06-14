local M = {}
local sessions = require "mini.sessions"

local session_loaded = false

local function encode(path)
  return path:gsub("/", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
end

local function current_session_name() return encode(vim.fn.getcwd()) end

function M.restore_session()
  local name = current_session_name()
  local detected = sessions.detected or {}
  if detected[name] then
    session_loaded = true
    local cwd = vim.fn.getcwd()
    sessions.read(name)
    vim.cmd.cd(cwd)
    return true
  end
  return false
end

function M.write_session()
  local name = current_session_name()
  sessions.write(name, { verbose = false })
end

local function register_auto_save()
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("session-auto-save", { clear = true }),
    once = true,
    callback = function()
      -- vim.notify(
      --   string.format(
      --     "this_session='%s' session_loaded=%s buftype='%s' file='%s'",
      --     vim.v.this_session,
      --     tostring(session_loaded),
      --     vim.bo.buftype,
      --     vim.fn.expand "%"
      --   ),
      --   vim.log.levels.INFO
      -- )
      if vim.v.this_session ~= "" then return end
      if session_loaded then return end
      if vim.bo.buftype ~= "" or vim.fn.expand "%" == "" then return end
      sessions.write(current_session_name(), { verbose = false })
    end,
  })
end

function M.reset()
  session_loaded = false
  vim.v.this_session = ""
  register_auto_save()
end

function M.setup()
  vim.keymap.set("n", "<leader>qs", M.restore_session, { desc = "Restore Session" })
  vim.keymap.set(
    "n",
    "<leader>ql",
    function() sessions.select() end,
    { desc = "Select Session" }
  )
  vim.keymap.set(
    "n",
    "<leader>qw",
    function() sessions.write() end,
    { desc = "Save Session" }
  )
  vim.keymap.set(
    "n",
    "<leader>qd",
    function() sessions.delete() end,
    { desc = "Delete Session" }
  )
  vim.keymap.set(
    "n",
    "<leader>R",
    function() sessions.restart() end,
    { desc = "Restart Neovim" }
  )

  register_auto_save()
end

return M
