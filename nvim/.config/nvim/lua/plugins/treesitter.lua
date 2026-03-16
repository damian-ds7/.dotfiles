return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    branch = "main",
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
    end,
    build = ":TSUpdate",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    branch = "main",
  },
  {
    {
      "MeanderingProgrammer/treesitter-modules.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-S-space>",
            node_decremental = "<BS>",
          },
        },
      },
    },
  },
}
