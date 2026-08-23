vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.timeoutlen = vim.g.vscode and 1000 or 300

local opt = vim.o

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "line"
opt.signcolumn = "yes"
opt.showmode = false
opt.ruler = false
opt.pumblend = 10
opt.pumheight = 10
opt.conceallevel = 1
vim.g.have_nerd_font = false
opt.cmdheight = vim.g.vscode and 0 or 1
opt.laststatus = 3

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.breakindent = true
opt.linebreak = true
opt.wrap = false
opt.formatoptions = "jcroqlnt"
vim.g.markdown_recommended_style = 0

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit"
opt.wildmode = "longest:full,full"
opt.shortmess = opt.shortmess .. "WcC"

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.winminwidth = 5
if vim.version().minor >= 13 then
  opt.scrolloff = 99
  opt.scrolloffpad = 1
else
  opt.scrolloff = 10
end
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.jumpoptions = "stack,view"

opt.mouse = "a"
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.confirm = true
opt.autowrite = true
opt.completeopt = "menu,menuone,noselect"

local function is_tmux() return vim.env.TMUX ~= nil end

if is_tmux() then
  local copy = { "tmux", "load-buffer", "-w", "-" }
  local paste =
    { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
  vim.g.clipboard = {
    name = "tmux",
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = 0,
  }
elseif vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste "+",
      ["*"] = require("vim.ui.clipboard.osc52").paste "*",
    },
  }
end
vim.opt.clipboard = "unnamedplus"

opt.spell = false
opt.spelllang = "en,pl"

opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldinner = " ",
  foldclose = "",
}
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.virtualedit = "block"

opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.sessionoptions = "buffers,curdir,tabpages,winsize,help,folds,skiprtp"
opt.exrc = true
