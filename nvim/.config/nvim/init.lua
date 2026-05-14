vim.loader.enable()
_G.lazy = require "utils.lazy-require"

require "config.options"
require "config.keymaps"
require "config.autocmds"
require "config.cmds"
require "config.pack"
require "config.lsp"

if not vim.g.vscode then
  vim.cmd("colorscheme " .. require("utils.colorscheme").get_colorscheme())
end
