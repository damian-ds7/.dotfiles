local M = {}

local last_editor_size = { cols = vim.o.columns, lines = vim.o.lines }

local state = {
  term = { buf = -1, win = -1, mode = "floating" },
  float_dims = nil,
  split_dims = { h_ratio = 0.3 },
}

local function get_dims()
  local d = state.float_dims
  if not d then return require("utils.float").floating_window_dims() end
  local ew = vim.o.columns
  local eh = vim.o.lines
  return math.floor(d.w_ratio * ew),
    math.floor(d.h_ratio * eh),
    math.floor(d.col_ratio * ew),
    math.floor(d.row_ratio * eh)
end

local group = vim.api.nvim_create_augroup("float-terminal", { clear = true })

vim.api.nvim_create_autocmd("WinResized", {
  group = group,
  desc = "Save new window size as ratios",
  callback = function()
    local cols, lines = vim.o.columns, vim.o.lines
    local is_vim_resize = cols ~= last_editor_size.cols
      or lines ~= last_editor_size.lines
    last_editor_size = { cols = cols, lines = lines }

    if is_vim_resize then return end

    if not vim.api.nvim_win_is_valid(state.term.win) then return end

    local win = state.term.win
    local ew = vim.o.columns
    local eh = vim.o.lines

    if state.term.mode == "floating" then
      local cfg = vim.api.nvim_win_get_config(win)
      state.float_dims = {
        w_ratio = cfg.width / ew,
        h_ratio = cfg.height / eh,
        col_ratio = cfg.col / ew,
        row_ratio = cfg.row / eh,
      }
    elseif state.term.mode == "bottom" then
      state.split_dims.h_ratio = vim.api.nvim_win_get_height(win) / eh
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Resize floating terminal window",
  callback = function()
    if not vim.api.nvim_win_is_valid(state.term.win) then return end
    if state.term.mode ~= "floating" then return end -- add this

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

    if vim.api.nvim_win_is_valid(state.term.win) then
      vim.api.nvim_win_close(state.term.win, true)
    end

    state.term.win = -1
    state.term.buf = -1
    state.split_dims = { h_ratio = 0.3 }
    state.float_dims = nil
  end,
})

local function setup_terminal_keymaps(buf)
  vim.keymap.set(
    "n",
    "q",
    function() M.toggle_terminal { mode = state.term.mode } end,
    { buffer = buf, silent = true, desc = "Close terminal" }
  )
end

local function create_floating_window(opts)
  local width, height, col, row = get_dims()

  local buf = (vim.api.nvim_buf_is_valid(opts.buf)) and opts.buf
    or vim.api.nvim_create_buf(false, true)

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
  local height = math.floor(state.split_dims.h_ratio * vim.o.lines)
  local width = vim.o.columns

  local buf = vim.api.nvim_buf_is_valid(opts.buf) and opts.buf
    or vim.api.nvim_create_buf(false, true)

  vim.cmd "botright split"

  local win = vim.api.nvim_get_current_win()

  if vim.version().minor < 13 then
    -- TODO: remove
    ---@diagnostic disable-next-line: deprecated
    vim.api.nvim_win_set_height(win, height)
  else
    vim.api.nvim_win_resize(win, width, height)
  end

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
      setup_terminal_keymaps(state.term.buf)
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

    local dir = args
      :gsub("%-%-bottom", "")
      :gsub("%-%-floating", "")
      :gsub("^%s+", "")
      :gsub("%s+$", "")

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
