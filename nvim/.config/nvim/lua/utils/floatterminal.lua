local M = {}

local state = {
  floating = { buf = -1, win = -1 },
}

local nvim_id = vim.v.servername:gsub("[^%a%d]", "-"):lower()
local tmux_prefix = "nvim-term-" .. nvim_id

local function create_native_window(opts)
  local width, height = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
  local col, row = math.floor((vim.o.columns - width) / 2), math.floor((vim.o.lines - height) / 2)
  local buf = (vim.api.nvim_buf_is_valid(opts.buf)) and opts.buf or vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })
  return { buf = buf, win = win }
end

local function create_tmux_window(dir)
  local dir_slug = dir:gsub("[^%a%d]", "-"):gsub("%-+", "-"):lower()
  local session_id = string.format("%s-%s", tmux_prefix, dir_slug)
  local nvim_server = vim.v.servername

  local has_session = os.execute("tmux has-session -t " .. session_id .. " 2>/dev/null")

  if not has_session then
    local cmd = string.format('tmux new-session -d -s "%s" -c "%s" -e "NVIM_ADDRESS=%s"', session_id, dir, nvim_server)
    vim.fn.system(cmd)
    vim.fn.system(string.format('tmux set-option -t "%s" status off', session_id))
  end

  local popup_cmd = string.format('tmux display-popup -d "%s" -xC -yC -w80%% -h80%% -E "tmux attach-session -t %s"', dir, session_id)
  vim.fn.system(popup_cmd)
end

local autocmd_created = false

M.toggle_floating_terminal = function(dir)
  if os.getenv "TMUX" then
    if not autocmd_created then
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          local cmd = string.format("tmux list-sessions -F '#S' | grep '^%s' | xargs -I {} tmux kill-session -t {} 2>/dev/null", tmux_prefix)
          vim.fn.system(cmd)
        end,
      })
      autocmd_created = true
    end

    create_tmux_window(dir)
  else
    if not vim.api.nvim_win_is_valid(state.floating.win) then
      vim.env.NVIM_ADDRESS = vim.v.servername
      state.floating = create_native_window { buf = state.floating.buf }
      if dir then vim.api.nvim_set_current_dir(dir) end
      if vim.bo[state.floating.buf].buftype ~= "terminal" then
        vim.cmd.terminal()
        vim.bo[state.floating.buf].buflisted = false
      end

      vim.api.nvim_create_autocmd("TermClose", {
        buffer = state.floating.buf,
        callback = function()
          if vim.api.nvim_win_is_valid(state.floating.win) then
            vim.api.nvim_win_close(state.floating.win, true)
            state.floating.win = -1
          end
        end,
      })
      vim.cmd "startinsert"
    else
      vim.api.nvim_win_hide(state.floating.win)
    end
  end
end

M.setup = function()
  vim.api.nvim_create_user_command("FloatTerm", function(opts)
    local dir
    if opts.args ~= "" then
      dir = vim.fn.expand(opts.args)
    else
      dir = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
    end

    M.toggle_floating_terminal(dir)
  end, {
    nargs = "?",
    complete = "dir",
    desc = "Toggle Floating Terminal (Optional: path)",
  })
end

return M
