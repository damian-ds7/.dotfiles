local utils = require "utils.pack"

local config = function()
  local ts = require "nvim-treesitter"

  local ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "diff",
    "dockerfile",
    "go",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "latex",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
    "zsh",
  }

  local registry = require("core.lang_reg").get_all()
  if registry.treesitter then vim.list_extend(ensure_installed, registry.treesitter) end

  ts.install(ensure_installed)
  -- NOTE: If languages fail to install or compilation hangs,
  -- ensure 'tree-sitter-cli' is installed (e.g., :MasonInstall tree-sitter-cli).
  -- If the issue persists, run :checkhealth nvim-treesitter to diagnose.

  ts.install(ensure_installed)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = ensure_installed,
    callback = function() vim.treesitter.start() end,
  })
end

utils.add({ src = utils.gh "nvim-treesitter/nvim-treesitter", data = { vscode = true } }, config, "later")

utils.on_pack_changed("nvim-treesitter", "update", function(data)
  if not data.active then vim.cmd.packadd "nvim-treesitter" end
  vim.cmd "TSUpdate"
end)

utils.add(
  { src = utils.gh "nvim-treesitter/nvim-treesitter-textobjects", data = { vscode = true } },
  function() vim.g.no_plugin_maps = true end,
  "event:BufReadPost,BufWritePost,BufNewFile"
)

utils.add(
  { src = utils.gh "andymass/vim-matchup", data = { vscode = true } },
  function()
    require("match-up").setup {
      treesitter = {
        stopline = 500,
      },
    }
  end,
  "event:BufReadPost,BufWritePost,BufNewFile"
)
