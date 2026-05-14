return {
  plugin {
    src = "nvim-treesitter/nvim-treesitter",
    lazy = true,
    vscode = true,
    pack_changed = { kind = "update", action = "TSUpdate" },
    config = function()
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
      if registry.treesitter then
        vim.list_extend(ensure_installed, registry.treesitter)
      end

      ts.install(ensure_installed)
      -- NOTE: If languages fail to install or compilation hangs,
      -- ensure 'tree-sitter-cli' is installed (e.g., :MasonInstall tree-sitter-cli).
      -- If the issue persists, run :checkhealth nvim-treesitter to diagnose.

      ts.install(ensure_installed)

      local ts_group =
        vim.api.nvim_create_augroup("treesitter-auto-start", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = ts_group,
        pattern = ensure_installed,
        desc = "Start Treesitter for installed languages",
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
  plugin {
    src = "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    vscode = true,
    config = function() vim.g.no_plugin_maps = true end,
  },
  plugin {
    src = "andymass/vim-matchup",
    name = "match-up",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    vscode = true,
    opts = {
      treesitter = {
        stopline = 500,
      },
    },
  },
}
