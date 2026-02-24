return {
  "NickvanDyke/opencode.nvim",
  dependencies = { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  keys = {
    { "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask opencode" },
    { "<leader>ax", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Execute opencode action…" },
    { "<leader>at", function() require("opencode").toggle() end, mode = { "n", "x" }, desc = "Toggle opencode" },
    { "go", function() return require("opencode").operator "@this " end, expr = true, mode = { "n", "x" }, desc = "Add range to opencode" },
    { "goo", function() return require("opencode").operator "@this " .. "_" end, expr = true, desc = "Add line to opencode" },
    { "<S-C-u>", function() require("opencode").command "session.half.page.up" end, desc = "opencode half page up" },
    { "<S-C-d>", function() require("opencode").command "session.half.page.down" end, desc = "opencode half page down" },
  },
  config = function()
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then wk.add { { "<leader>a", group = "AI" } } end

    local opencode_cmd = "opencode --port"
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = "right",
        enter = false,
        on_win = function(win)
          -- Set up keymaps and cleanup for an arbitrary terminal
          require("opencode.terminal").setup(win.win)
        end,
      },
    }
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function() require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts) end,
        stop = function() require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close() end,
        toggle = function() require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts) end,
      },
    }
  end,
}
