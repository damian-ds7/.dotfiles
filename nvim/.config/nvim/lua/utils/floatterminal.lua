local M = {}

local state = {
  floating = { buf = -1, win = -1 },
}

local function create_native_window(opts)
  local function get_dims()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.9)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) * 0.2)
    return width, height, col, row
  end

  local width, height, col, row = get_dims()

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

  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then return end

      local w, h, c, r = get_dims()

      vim.api.nvim_win_set_config(win, {
        relative = "editor",
        width = w,
        height = h,
        col = c,
        row = r,
      })
    end,
  })

  return { buf = buf, win = win }
end

M.toggle_floating_terminal = function(dir)
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
