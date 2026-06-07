return {
  plugin {
    src = "nvim-mini/mini.nvim",
    vscode = true,
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      local spec_treesitter = require("mini.ai").gen_spec.treesitter
      local ai = require "mini.ai"
      require("mini.ai").setup {
        custom_textobjects = {
          o = spec_treesitter {
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          },
          f = spec_treesitter { a = "@function.outer", i = "@function.inner" },
          c = spec_treesitter { a = "@class.outer", i = "@class.inner" },
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" },
          e = {
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
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

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add {
          { "aB", desc = "around buffer", mode = { "o", "x" } },
          { "aI", desc = "around indent", mode = { "o", "x" } },
          { "aL", desc = "around line", mode = { "o", "x" } },
          { "af", desc = "around function", mode = { "o", "x" } },
          { "ac", desc = "around class", mode = { "o", "x" } },

          { "iB", desc = "inside buffer", mode = { "o", "x" } },
          { "iI", desc = "inside indent", mode = { "o", "x" } },
          { "iL", desc = "inside line", mode = { "o", "x" } },
          { "if", desc = "inside function", mode = { "o", "x" } },
          { "ic", desc = "inside class", mode = { "o", "x" } },
        }
      end

      require("mini.pairs").setup {
        modes = { insert = true, command = false, terminal = false },
        mappings = {
          ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
          ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
          ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

          [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
          ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
          ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },

          ['"'] = {
            action = "closeopen",
            pair = '""',
            neigh_pattern = "^[^\\]",
            register = { cr = false },
          },
          ["'"] = {
            action = "closeopen",
            pair = "''",
            neigh_pattern = "^[^%a\\]",
            register = { cr = false },
          },
          ["`"] = false,
        },
      }

      require("mini.surround").setup {
        mappings = {
          add = "gza",
          delete = "gzd",
          find = "gzf",
          find_left = "gzF",
          highlight = "gzh",
          replace = "gzr",
          update_n_lines = "gzn",
        },
      }
    end,
  },
  plugin {
    src = "nvim-mini/mini.icons",
    config = function()
      require("mini.icons").setup {
        file = {
          [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        },
        filetype = {
          dotenv = { glyph = "", hl = "MiniIconsYellow" },
        },
      }
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  plugin {
    src = "nvim-mini/mini.sessions",
    config = function()
      require("mini.sessions").setup {
        force = {
          read = false,
          write = true,
          delete = true,
        },
      }
      require("utils.session").setup()
    end,
  },
}
