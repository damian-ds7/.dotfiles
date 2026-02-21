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
      }

      local registry = require "core.lang_reg"
      for _, lang in ipairs(registry.get_all()) do
        if lang.treesitter then vim.list_extend(ensure_installed, lang.treesitter) end
      end

      ts.setup {}
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
}
