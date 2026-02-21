vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.timeoutlen = vim.g.vscode and 1000 or 300

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false
opt.ruler = false
opt.pumblend = 10
opt.pumheight = 10
opt.conceallevel = 2
vim.g.have_nerd_font = false
opt.cmdheight = 0
opt.laststatus = 3

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 2
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
opt.shortmess:append { W = true, I = true, c = true, C = true }

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.winminwidth = 5
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.jumpoptions = "view"

opt.mouse = "a"
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.confirm = true
opt.autowrite = true
opt.completeopt = "menu,menuone,noselect"
vim.g.autoformat = true

opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

opt.spell = true
opt.spelllang = { "en" }

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.virtualedit = "block"

opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
