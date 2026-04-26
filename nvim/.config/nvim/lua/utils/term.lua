local M = {}

local state = {
  term = { buf = -1, win = -1, mode = "floating" },
}

local group = vim.api.nvim_create_augroup("float-terminal", { clear = true })

local function get_dims()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) * 0.2)
  return width, height, col, row
end

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Resize floating terminal window",
  callback = function()
    if not vim.api.nvim_win_is_valid(state.term.win) then return end

    local w, h, c, r = get_dims()

    vim.api.nvim_win_set_config(state.term.win, {
      relative = "editor",
      width = w,
      height = h,
      col = c,
      row = r,
    })
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = group,
  desc = "Close floating terminal window on TermClose",
  callback = function(ev)
    if ev.buf ~= state.term.buf then return end

    if vim.api.nvim_win_is_valid(state.term.win) then vim.api.nvim_win_close(state.term.win, true) end

    state.term.win = -1
  end,
})

local function create_floating_window(opts)
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

  return { buf = buf, win = win }
end

local function create_bottom_window(opts)
  local height = math.floor(vim.o.lines * 0.3)

  local buf = vim.api.nvim_buf_is_valid(opts.buf) and opts.buf or vim.api.nvim_create_buf(false, true)

  vim.cmd "botright split"

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win, height)
  vim.api.nvim_win_set_buf(win, buf)

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = false
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].spell = false
  vim.wo[win].list = false

  return { buf = buf, win = win }
end

M.toggle_terminal = function(opts)
  opts = opts or {}
  local dir = opts.dir
  local mode = opts.mode

  local win_valid = vim.api.nvim_win_is_valid(state.term.win)

  if win_valid and state.term.mode ~= mode then
    vim.api.nvim_win_close(state.term.win, true)
    state.term.win = -1
    win_valid = false
  end

  if not win_valid then
    vim.env.NVIM_ADDRESS = vim.v.servername

    if mode == "bottom" then
      state.term = vim.tbl_extend(
        "force",
        state.term,
        create_bottom_window {
          buf = state.term.buf,
        }
      )
    else
      state.term = vim.tbl_extend(
        "force",
        state.term,
        create_floating_window {
          buf = state.term.buf,
        }
      )
    end

    state.term.mode = mode

    if dir then vim.api.nvim_set_current_dir(dir) end

    if vim.bo[state.term.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
      vim.bo[state.term.buf].buflisted = false
    end

    vim.cmd "startinsert"
  else
    vim.api.nvim_win_hide(state.term.win)
  end
end

M.setup = function()
  vim.api.nvim_create_user_command("Terminal", function(opts)
    local args = opts.args or ""

    local mode = "floating"
    if args:find "--bottom" then
      mode = "bottom"
    elseif args:find "--floating" then
      mode = "floating"
    end

    local dir = args:gsub("%-%-bottom", ""):gsub("%-%-floating", ""):gsub("^%s+", ""):gsub("%s+$", "")

    if dir ~= "" then
      dir = vim.fn.expand(dir)
    else
      dir = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
    end

    M.toggle_terminal {
      dir = dir,
      mode = mode,
    }
  end, {
    nargs = "*",
    complete = "dir",
    desc = "Terminal (--floating | --bottom) [path]",
  })

  vim.api.nvim_create_user_command("TermToggle", function()
    local mode = state.term.mode or "floating"

    local dir = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()

    M.toggle_terminal {
      dir = dir,
      mode = mode,
    }
  end, {
    desc = "Toggle Terminal (last used mode)",
  })
end

return M
