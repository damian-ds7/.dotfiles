local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    if vim.version().minor < 13 then
      -- TODO: remove
      vim.hl.on_yank()
    else
      vim.hl.hl_op()
    end
  end,
})

autocmd("ColorScheme", {
  desc = "Set inlay hints color",
  group = augroup("inlay-hints-bg", { clear = true }),
  callback = function() vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" }) end,
})

autocmd("BufWritePre", {
  desc = "Remove trailing whitespaces on save",
  group = augroup("trim-whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Remove scrolloff in terminal buffers",
  group = augroup("term-scrolloff", { clear = true }),
  callback = function()
    vim.opt_local.scrolloff = 0
    if vim.version().minor >= 13 then vim.opt_local.scrolloffpad = 0 end
  end,
})

autocmd({ "BufWinEnter", "WinEnter" }, {
  group = augroup("term-insert", { clear = true }),
  pattern = "term://*",
  command = "startinsert",
})

local cursorline_augroup = augroup("cursorline-active-window", { clear = true })

local function is_regular_win(win)
  if not vim.api.nvim_win_is_valid(win) then return false end
  local buf = vim.api.nvim_win_get_buf(win)
  local bt = vim.bo[buf].buftype
  return bt ~= "terminal" and bt ~= "nofile"
end

autocmd("WinEnter", {
  desc = "Enable cursorline on active window",
  group = cursorline_augroup,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    -- Schedule to preserve the correct order of events when synchronously
    -- changing between windows a bunch of times (like in `<c-w>t`)
    vim.schedule(function()
      if not is_regular_win(win) then return end
      if not vim.api.nvim_win_is_valid(win) then return end
      if not vim.w[win].cached_cursorline then return end

      vim.wo[win].cursorline = vim.w[win].cached_cursorline
      vim.w[win].cached_cursorline = nil
    end)
  end,
})

autocmd("WinLeave", {
  group = cursorline_augroup,
  desc = "Disable cursorline for inactive window",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    -- Copying the current window options seems to be done after `WinLeave`
    -- when opening a new tab. Delay setting `cursorline` to `false` until
    -- after the options are copied
    vim.schedule(function()
      if not is_regular_win(win) then return end
      if not vim.api.nvim_win_is_valid(win) then return end
      vim.w[win].cached_cursorline = vim.wo[win].cursorline
      vim.wo[win].cursorline = false
    end)
  end,
})

autocmd("TermClose", {
  group = cursorline_augroup,
  desc = "Restore cursorline after lazygit closes",
  callback = function(ev)
    if not vim.api.nvim_buf_is_valid(ev.buf) then return end
    if not vim.api.nvim_buf_get_name(ev.buf):find "lazygit" then return end
    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      if not is_regular_win(win) then return end
      vim.wo[win].cursorline = true
    end)
  end,
})

autocmd("VimEnter", {
  group = augroup("makrdown-codeblock-conceal", { clear = true }),
  callback = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.fn.matchadd("Conceal", "```", 10, -1, { conceal = "⋯" })
      end,
    })
  end,
})

-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--   pattern = "*.md",
--   callback = function()
--     local node = vim.treesitter.get_node()
--     local in_block = false
--     while node do
--       if node:type() == "fenced_code_block" then
--         in_block = true
--         break
--       end
--       node = node:parent()
--     end
--     vim.wo.conceallevel = in_block and 0 or 1
--   end,
-- })
