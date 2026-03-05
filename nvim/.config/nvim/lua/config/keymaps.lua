local map = vim.keymap.set

-- Essentials
map("i", "jj", "<Esc>", { noremap = true })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("x", "p", "P", { desc = "Paste without overwriting register" })
map("x", "P", "p", { desc = "Paste and overwrite register" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
vim.keymap.set("n", "<leader>fn", function()
  local rel_dir = vim.fn.expand "%:h"

  if rel_dir == "." or rel_dir == "" then
    rel_dir = ""
  else
    rel_dir = rel_dir .. "/"
  end

  vim.ui.input({
    prompt = "New File (relative to CWD): ",
    default = rel_dir,
  }, function(input)
    if not input or input == "" then return end

    local full_path = vim.fn.getcwd() .. "/" .. input
    local dir = vim.fn.fnamemodify(full_path, ":h")

    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end

    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.cmd "write"

    vim.notify("Created: " .. input, vim.log.levels.INFO, { title = "File System" })
  end)
end, { desc = "New File (Relative Path)" })

-- Better Movement & Indenting
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Search & View Handling
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlighting" })
map("n", "<C-d>", "<C-d>zz", { desc = "Jump half page down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Jump half page up and center" })

-- Center search results
map("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Navigation (CTRL + hjkl)
map("n", "<C-h>", "<C-w><C-h>", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Go to right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Go to upper window" })

-- Moving Windows (CTRL + SHIFT + hjkl)
map("n", "<C-S-h>", "<C-w>H", { desc = "Move window left" })
map("n", "<C-S-l>", "<C-w>L", { desc = "Move window right" })
map("n", "<C-S-j>", "<C-w>J", { desc = "Move window down" })
map("n", "<C-S-k>", "<C-w>K", { desc = "Move window up" })

-- Splits & Resizing
map("n", "<leader>-", "<C-W>s", { desc = "Split Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

-- Tabs
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()

  vim.cmd "silent! write"

  for _, buf in ipairs(all_bufs) do
    if
      buf ~= current_buf
      and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
    then
      local success = pcall(vim.api.nvim_buf_delete, buf, { force = false })
      if not success then break end
    end
  end
end, { desc = "Close All Other Listed Buffers" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Writing helpers
map("i", "<A-.>", " -> ", { silent = true })
map("v", "<leader>p", '"_dP', { desc = "Paste without yanking" })
map("i", ",", ",<c-g>u") -- Undo breakpoints
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Comment Above" })

-- Quickfix & Location List
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Diagnostic Jumps
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    }
  end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

if not vim.g.vscode then
  require("utils.floatterminal").setup()
  map("n", "<leader>fT", ":FloatTerm %:p:h<CR>", {
    desc = "Toggle Floating Terminal (File Dir)",
    silent = true,
  })

  map("n", "<leader>ft", ":FloatTerm<CR>", {
    desc = "Toggle Floating Terminal (Project Root)",
    silent = true,
  })
else
  local vscode = require "vscode"
  for _, lhs in ipairs { "<leader>ft", "<leader>fT", "<c-/>" } do
    vim.keymap.set("n", lhs, function() vscode.call "workbench.action.terminal.toggleTerminal" end)
  end
  vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
  vim.keymap.set("n", "<leader>/", function() vscode.call "workbench.action.findInFiles" end)

  vim.keymap.set("n", "<S-h>", function() vscode.call "workbench.action.previousEditor" end)
  vim.keymap.set("n", "<S-l>", function() vscode.call "workbench.action.nextEditor" end)
end
