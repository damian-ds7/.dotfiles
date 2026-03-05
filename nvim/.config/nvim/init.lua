require "config.options"
require "config.keymaps"
require "config.autocmds"
require "config.lazy"
require "config.lsp"

if not vim.g.vscode then vim.cmd("colorscheme " .. require("utils.colorscheme").get_colorscheme()) end
