require "config.options"
require "config.keymaps"
require "config.autocmds"
require "config.lazy"
require "config.lsp"

vim.cmd("colorscheme " .. require("utils.colorscheme").get_colorscheme())
