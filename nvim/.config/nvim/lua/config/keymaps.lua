local map = vim.keymap.set

map("i", "jj", "<Esc>", { noremap = true })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("x", "p", "P", { desc = "Paste without overwriting register" })
map("x", "P", "p", { desc = "Paste and overwrite register" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

---@param path string
local create_and_open = function(path)
  local dir = vim.fs.dirname(path)
  local name = vim.fs.basename(path)

  if vim.uv.fs_stat(dir).type == "directory" then vim.fn.mkdir(dir, "p") end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
  vim.cmd "write"

  vim.notify("Created: " .. name, vim.log.levels.INFO, { title = "File System" })
end

---@param opts { base_dir?: string, prompt?: string }
local new_file_prompt = function(opts)
  vim.ui.input({
    prompt = opts.prompt,
  }, function(input)
    if not input or input == "" then return end

    local full_path = opts.base_dir .. "/" .. input
    create_and_open(full_path)
  end)
end

map("n", "<leader>fn", function()
  local rel_dir = vim.fn.expand "%:h"

  if rel_dir == "." or rel_dir == "" then rel_dir = "" end

  new_file_prompt { base_dir = rel_dir, prompt = "New File (Relative)" }
end, { desc = "New File (Relative)" })
map(
  "n",
  "<leader>fN",
  function() new_file_prompt { base_dir = vim.uv.cwd(), prompt = "New File (Root)" } end,
  { desc = "New File (Root)" }
)

map(
  { "n", "x" },
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { desc = "Down", expr = true, silent = true }
)
map(
  { "n", "x" },
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { desc = "Up", expr = true, silent = true }
)
map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlighting" })
if vim.version().minor < 13 then
  map("n", "<C-d>", "<C-d>zz", { desc = "Jump half page down and center" })
  map("n", "<C-u>", "<C-u>zz", { desc = "Jump half page up and center" })
end

if vim.version().minor < 13 then
  map(
    "n",
    "n",
    "'Nn'[v:searchforward].'zzzv'",
    { expr = true, desc = "Next Search Result" }
  )
  map(
    "n",
    "N",
    "'nN'[v:searchforward].'zzzv'",
    { expr = true, desc = "Prev Search Result" }
  )
  map(
    { "x", "o" },
    "n",
    "'Nn'[v:searchforward]",
    { expr = true, desc = "Next Search Result" }
  )
  map(
    { "x", "o" },
    "N",
    "'nN'[v:searchforward]",
    { expr = true, desc = "Prev Search Result" }
  )
end

map("n", "<C-h>", "<C-w><C-h>", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Go to right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Go to upper window" })

map("n", "<C-S-h>", "<C-w>H", { desc = "Move window left" })
map("n", "<C-S-l>", "<C-w>L", { desc = "Move window right" })
map("n", "<C-S-j>", "<C-w>J", { desc = "Move window down" })
map("n", "<C-S-k>", "<C-w>K", { desc = "Move window up" })

map("n", "<leader>-", "<C-W>s", { desc = "Split Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

local resize = require("utils.resize").resize

map(
  { "n", "t" },
  "<C-Up>",
  function() resize("up", 2) end,
  { desc = "Increase Height" }
)
map(
  { "n", "t" },
  "<C-Down>",
  function() resize("down", 2) end,
  { desc = "Decrease Height" }
)
map(
  { "n", "t" },
  "<C-Left>",
  function() resize("left", 2) end,
  { desc = "Decrease Width" }
)
map(
  { "n", "t" },
  "<C-Right>",
  function() resize("right", 2) end,
  { desc = "Increase Width" }
)

map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })

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

local function move(direction)
  local count = vim.v.count1
  if direction == "down" then
    vim.cmd("move .+" .. count)
  else
    vim.cmd("move .-" .. (count + 1))
  end
  vim.cmd "normal! =="
end

local function move_visual(direction)
  local count = vim.v.count1
  vim.cmd("normal! " .. vim.keycode "<Esc>")
  if direction == "down" then
    vim.cmd("'<,'>move '>+" .. count)
  else
    vim.cmd("'<,'>move '<-" .. (count + 1))
  end
  vim.cmd "normal! gv=gv"
end

map("n", "<A-j>", function() move "down" end, { desc = "Move Line Down" })
map("n", "<A-k>", function() move "up" end, { desc = "Move Line Up" })
map("i", "<A-j>", function()
  vim.cmd "stopinsert"
  move "down"
  vim.cmd "startinsert"
end, { desc = "Move Line Down" })

map("i", "<A-k>", function()
  vim.cmd "stopinsert"
  move "up"
  vim.cmd "startinsert"
end, { desc = "Move Line Up" })
map("v", "<A-j>", function() move_visual "down" end, { desc = "Move Line Down" })
map("v", "<A-k>", function() move_visual "up" end, { desc = "Move Line Up" })

map("i", "<A-.>", " -> ", { silent = true })
map("i", "<A-,>", " <- ", { silent = true })
map("v", "<leader>p", '"_dP', { desc = "Paste without yanking" })

local function yank_as_codeblock(lang)
  vim.cmd 'normal! "zy'

  local text = vim.fn.getreg "z"
  local lines = vim.split(text, "\n", { plain = true })

  local fence = "```" .. (lang or "")
  table.insert(lines, 1, fence)
  table.insert(lines, "```")

  local result = table.concat(lines, "\n") .. "\n"

  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)

  vim.notify(
    "Copied as code block" .. ((lang or "") ~= "" and (" [" .. lang .. "]") or ""),
    vim.log.levels.INFO
  )
end

vim.keymap.set(
  "v",
  "<leader>yc",
  function() yank_as_codeblock "" end,
  { desc = "Yank as code block" }
)

vim.keymap.set("v", "<leader>yC", function()
  vim.ui.input({ prompt = "Language: " }, function(input)
    if input ~= nil then yank_as_codeblock(input) end
  end)
end, { desc = "Yank as code block (with language)" })

map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Comment Above" })

map("n", "<leader>xq", function()
  local success, err = pcall(
    vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen
  )
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

map("n", "<leader>xl", function()
  local success, err = pcall(
    vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen
  )
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float { bufnr = bufnr, scope = "cursor", focus = false }
      end,
    }
  end
end

map(
  "n",
  "<leader>cd",
  function() vim.diagnostic.open_float() end,
  { desc = "LSP: Line Diagnostics" }
)
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set(
  { "n", "x" },
  "<C-space>",
  function() require("vim.treesitter._select").select_parent(vim.v.count1) end,
  { desc = "Expand treesitter selection" }
)

vim.keymap.set(
  "x",
  "<BS>",
  function() require("vim.treesitter._select").select_child(vim.v.count1) end,
  { desc = "Shrink treesitter selection" }
)

if not vim.g.vscode then
  require("utils.term").setup()
  map("n", "<leader>of", ":Terminal --floating<CR>", { desc = "Float Term" })
  map("n", "<leader>ob", ":Terminal --bottom<CR>", { desc = "Bottom Term" })

  map(
    "n",
    "<leader>oF",
    ":Terminal --floating %:p:h<CR>",
    { desc = "Float Term (file)" }
  )
  map(
    "n",
    "<leader>oB",
    ":Terminal --bottom %:p:h<CR>",
    { desc = "Bottom Term (file)" }
  )
else
  local vscode = require "vscode"
  for _, lhs in ipairs { "<leader>ft", "<leader>fT", "<c-/>" } do
    vim.keymap.set(
      "n",
      lhs,
      function() vscode.call "workbench.action.terminal.toggleTerminal" end
    )
  end
  vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
  vim.keymap.set(
    "n",
    "<leader>/",
    function() vscode.call "workbench.action.findInFiles" end
  )

  vim.keymap.set(
    "n",
    "<S-h>",
    function() vscode.call "workbench.action.previousEditor" end
  )
  vim.keymap.set("n", "<S-l>", function() vscode.call "workbench.action.nextEditor" end)
end
