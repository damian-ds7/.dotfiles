local utils = require "utils.pack"

_G.dd = function(...) require("snacks").debug.inspect(...) end
_G.bt = function() require("snacks").debug.backtrace() end

vim.print = _G.dd

utils.add(utils.gh "folke/snacks.nvim", function()
  local snacks = require "snacks"

  snacks.setup {
    bigfile = { enabled = true },
    indent = {
      indent = {
        enabled = false,
      },
      scope = {
        enabled = true,
      },
    },
    gitbrowse = { enabled = true },
    lazygit = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    image = { enabled = true },
    zen = {
      zoom = {
        center = true,
        show = { statusline = true, tabline = true },
        win = {
          backdrop = { transparent = true, blend = 40 },
          width = 150,
        },
      },
    },
  }

  snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
  snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
  snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
  snacks.toggle.diagnostics():map "<leader>ud"
  snacks.toggle.line_number():map "<leader>ul"
  snacks.toggle
    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map "<leader>uc"
  snacks.toggle.treesitter():map "<leader>uT"
  snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>ub"
  snacks.toggle.inlay_hints():map "<leader>uh"
  snacks.toggle
    .new({
      name = "Code Lens",
      get = function() return vim.lsp.codelens.is_enabled { bufnr = buf } end,
      set = function() vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled { bufnr = buf }) end,
    })
    :map "<leader>ue"
  snacks.toggle.indent():map "<leader>ug"
  snacks.toggle.dim():map "<leader>uD"
end)

vim.keymap.set("n", "<leader>gb", function() require("snacks").picker.git_branches() end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function() require("snacks").picker.git_log() end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function() require("snacks").picker.git_log_line() end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function() require("snacks").picker.git_status() end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function() require("snacks").picker.git_stash() end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function() require("snacks").picker.git_diff() end, { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", function() require("snacks").picker.git_log_file() end, { desc = "Git Log File" })
vim.keymap.set("n", "<leader>gi", function() require("snacks").picker.gh_issue() end, { desc = "GitHub Issues (open)" })
vim.keymap.set(
  "n",
  "<leader>gI",
  function() require("snacks").picker.gh_issue { state = "all" } end,
  { desc = "GitHub Issues (all)" }
)
vim.keymap.set(
  "n",
  "<leader>gp",
  function() require("snacks").picker.gh_pr() end,
  { desc = "GitHub Pull Requests (open)" }
)
vim.keymap.set(
  "n",
  "<leader>gP",
  function() require("snacks").picker.gh_pr { state = "all" } end,
  { desc = "GitHub Pull Requests (all)" }
)
vim.keymap.set("n", '<leader>s"', function() require("snacks").picker.registers() end, { desc = "Registers" })
vim.keymap.set("n", "<leader>uz", function() require("snacks").zen() end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>uZ", function() require("snacks").zen.zoom() end, { desc = "Toggle Zoom" })
vim.keymap.set("n", "<leader>>", function() require("snacks").scratch() end, { desc = "Toggle Scratch Buffer" })
vim.keymap.set("n", "<leader>S", function() require("snacks").scratch.select() end, { desc = "Select Scratch Buffer" })
vim.keymap.set("n", "<leader>cf", function() require("snacks").rename.rename_file() end, { desc = "Rename File" })
vim.keymap.set({ "n", "v" }, "<leader>gB", function() require("snacks").gitbrowse() end, { desc = "Git Browse" })
vim.keymap.set("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "Lazygit" })
vim.keymap.set(
  "n",
  "<leader>un",
  function() require("snacks").notifier.hide() end,
  { desc = "Dismiss All Notifications" }
)
vim.keymap.set(
  { "n", "t" },
  "]]",
  function() require("snacks").words.jump(vim.v.count1) end,
  { desc = "Next Reference" }
)
vim.keymap.set(
  { "n", "t" },
  "[[",
  function() require("snacks").words.jump(-vim.v.count1) end,
  { desc = "Prev Reference" }
)
