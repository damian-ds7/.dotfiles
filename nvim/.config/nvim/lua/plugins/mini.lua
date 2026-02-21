return {
  {
    "nvim-mini/mini.ai",
    dependencies = { "nvim-mini/mini.extra" },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      local spec_treesitter = require("mini.ai").gen_spec.treesitter
      local ai = require "mini.ai"
      return {
        custom_textobjects = {
          o = spec_treesitter { -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          },
          f = spec_treesitter { a = "@function.outer", i = "@function.inner" }, -- function
          c = spec_treesitter { a = "@class.outer", i = "@class.inner" }, -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call { name_pattern = "[%w_]" },
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      local wk = require "which-key"

      wk.add {
        -- Around text objects (Operator-pending and Visual modes)
        { "aB", desc = "around buffer", mode = { "o", "x" } },
        { "aI", desc = "around indent", mode = { "o", "x" } },
        { "aL", desc = "around line", mode = { "o", "x" } },
        { "af", desc = "around function", mode = { "o", "x" } },
        { "ac", desc = "around class", mode = { "o", "x" } },

        -- Inside text objects
        { "iB", desc = "inside buffer", mode = { "o", "x" } },
        { "iI", desc = "inside indent", mode = { "o", "x" } },
        { "iL", desc = "inside line", mode = { "o", "x" } },
        { "if", desc = "inside function", mode = { "o", "x" } },
        { "ic", desc = "inside class", mode = { "o", "x" } },
      }
    end,
  },
  {
    "nvim-mini/mini.pairs",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
  },
  {
    "nvim-mini/mini.surround",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add Surrounding" },
        { opts.mappings.delete, desc = "Delete Surrounding" },
        { opts.mappings.find, desc = "Find Right Surrounding" },
        { opts.mappings.find_left, desc = "Find Left Surrounding" },
        { opts.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.mappings.replace, desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
  },
}
