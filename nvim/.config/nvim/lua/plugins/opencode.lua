local utils = require "utils.pack"

utils.add("https://github.com/NickvanDyke/opencode.nvim", function()
  vim.cmd.packadd "snacks.nvim"

  local opencode_cmd = "opencode --port"

  ---@type snacks.terminal.Opts
  local snacks_terminal_opts = {
    win = {
      position = "right",
      enter = false,
      on_win = function(win) require("opencode.terminal").setup(win.win) end,
    },
  }

  ---@type opencode.Opts
  vim.g.opencode_opts = {
    server = {
      start = function() require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts) end,
      stop = function() require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close() end,
      toggle = function() require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts) end,
    },
    events = {
      enabled = true,
      reload = true,
      permissions = { enabled = false },
    },
  }
end, "later")

vim.keymap.set(
  { "n", "x" },
  "<leader>aa",
  function() require("opencode").ask("@this: ", { submit = true }) end,
  { desc = "Ask opencode" }
)

vim.keymap.set(
  { "n", "x" },
  "<leader>ax",
  function() require("opencode").select() end,
  { desc = "Execute opencode action…" }
)

vim.keymap.set({ "n", "x" }, "<leader>at", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

vim.keymap.set(
  { "n", "x" },
  "go",
  function() return require("opencode").operator "@this " end,
  { expr = true, desc = "Add range to opencode" }
)

vim.keymap.set(
  "n",
  "goo",
  function() return require("opencode").operator "@this " .. "_" end,
  { expr = true, desc = "Add line to opencode" }
)

vim.keymap.set(
  "n",
  "<S-C-u>",
  function() require("opencode").command "session.half.page.up" end,
  { desc = "opencode half page up" }
)

vim.keymap.set(
  "n",
  "<S-C-d>",
  function() require("opencode").command "session.half.page.down" end,
  { desc = "opencode half page down" }
)
