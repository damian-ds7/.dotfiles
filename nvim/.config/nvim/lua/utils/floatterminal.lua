local M = {}

local state = {
  floating = { buf = -1, win = -1 },
}

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
  local session_id = "floating-nvim-" .. dir:gsub("[^%a%d]", "-"):gsub("%-+", "-"):lower()
  local nvim_server = vim.v.servername

  local has_session = os.execute("tmux has-session -t " .. session_id .. " 2>/dev/null")

  if not has_session then
    local cmd = string.format('tmux new-session -d -s "%s" -c "%s" -e "NVIM_ADDRESS=%s"', session_id, dir, nvim_server)
    vim.fn.system(cmd)
    vim.fn.system(string.format('tmux set-option -t "%s" status off', session_id))

    -- local cmd = string.format(
    --   "export NVIM_ADDRESS=%s; "
    --     .. "nv() { "
    --     .. "if [ $# -eq 0 ]; then echo 'Usage: nv <file>'; "
    --     .. 'elif [ -d "$1" ]; then echo "Error: $1 is a directory."; '
    --     .. "else "
    --     .. 'local fp=$(realpath "$1"); '
    --     .. 'nvim --server "$NVIM_ADDRESS" --remote "$fp"; '
    --     .. "tmux detach; "
    --     .. "fi; "
    --     .. "}; clear",
    --   nvim_server
    -- )
    --
    -- vim.fn.system(string.format("tmux send-keys -t %s %s Enter", session_id, vim.fn.shellescape(cmd)))
  end

  local popup_cmd = string.format('tmux display-popup -d "%s" -xC -yC -w80%% -h80%% -E "tmux attach-session -t %s"', dir, session_id)
  vim.fn.system(popup_cmd)
end

local function trigger_terminal(dir)
  if os.getenv "TMUX" then
    create_tmux_window(dir)
  else
    if not vim.api.nvim_win_is_valid(state.floating.win) then
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

M.toggle_project_root = function()
  local root = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
  trigger_terminal(root)
end

M.toggle_file_dir = function() trigger_terminal(vim.fn.expand "%:p:h") end

return M
