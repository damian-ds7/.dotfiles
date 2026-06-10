return {
  plugin {
    src = "nvim-treesitter/nvim-treesitter",
    lazy = true,
    vscode = true,
    pack_changed = { kind = "update", action = "TSUpdate" },
    config = function()
      local ts = require "nvim-treesitter"
      local reg = require "core.lang_reg"
      local misc = require "mini.misc"

      -- Base parsers always installed (language-agnostic / infra).
      local ensure_installed = {
        "regex",
        "diff",
        "dockerfile",
        "html",
        "javascript",
        "json",
        "markdown",
        "markdown_inline",
        "sql",
        "toml",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      vim.list_extend(ensure_installed, reg.get_eager_parsers())
      ts.install(ensure_installed)
      -- NOTE: If languages fail to install or compilation hangs,
      -- ensure 'tree-sitter-cli' is installed (e.g., :MasonInstall tree-sitter-cli).
      -- If the issue persists, run :checkhealth nvim-treesitter to diagnose.

      for _, ft in ipairs(reg.get_lazy_filetypes()) do
        misc.safely("filetype:" .. ft, function()
          local entry = reg.get_lazy_entry(ft)
          if not entry or #entry.parsers == 0 then return end
          ts.install(entry.parsers)
          pcall(vim.treesitter.start)
        end)
      end

      local ts_group =
        vim.api.nvim_create_augroup("treesitter-auto-start", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = ts_group,
        pattern = "*",
        desc = "Start Treesitter when parser is available",
        callback = function() pcall(vim.treesitter.start) end,
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
