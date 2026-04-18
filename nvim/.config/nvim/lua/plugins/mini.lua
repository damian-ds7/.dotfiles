local utils = require "utils.pack"

local function config()
  -- mini.ai
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

  -- mini.pairs
  require("mini.pairs").setup {
    modes = { insert = true, command = true, terminal = false },
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    skip_ts = { "string" },
    skip_unbalanced = true,
    markdown = true,
    mappings = {
      ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

      [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
      ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
      ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },

      ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "^[^\\]", register = { cr = false } },
      ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "^[^%a\\]", register = { cr = false } },
      ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "^[^\\]", register = { cr = false } },
    },
  }

  -- mini.surround
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
end

utils.add(
  { src = utils.gh "nvim-mini/mini.nvim", data = { vscode = true } },
  config,
  "event:BufReadPost,BufWritePost,BufNewFile"
)

utils.add(utils.gh "nvim-mini/mini.icons", function()
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
end)

utils.add(utils.gh "nvim-mini/mini.sessions", function()
  local sessions = require "mini.sessions"
  local session_loaded = false
  sessions.setup { force = { read = false, write = true, delete = true } }

  local function encode(path) return path:gsub("/", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "") end

  local function current_session_name() return encode(vim.fn.getcwd()) end

  local function restore_session()
    local name = current_session_name()
    local detected = require("mini.sessions").detected or {}

    if detected[name] then
      require("mini.sessions").read(name)
      session_loaded = true
    end
  end

  vim.keymap.set("n", "<leader>qs", restore_session, { desc = "Restore Session" })

  vim.keymap.set("n", "<leader>ql", function() sessions.select() end, { desc = "Select Session" })

  vim.keymap.set("n", "<leader>qw", function() sessions.write() end, { desc = "Save Current Session" })

  vim.keymap.set("n", "<leader>qd", function() sessions.delete() end, { desc = "Delete Current Session" })

  vim.keymap.set("n", "<leader>R", function() sessions.restart() end, { desc = "Restart Neovim" })

  vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function()
      if vim.bo.buftype ~= "" or vim.fn.expand "%" == "" then return end

      local name = current_session_name()
      local detected = sessions.detected or {}

      if detected[name] or not session_loaded then sessions.write(name, { verbose = false }) end
    end,
  })
end)
