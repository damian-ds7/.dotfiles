_G.dd = function(...) require("snacks").debug.inspect(...) end
_G.bt = function() require("snacks").debug.backtrace() end

vim.print = _G.dd

local map = vim.keymap.set

map(
  "n",
  "<leader>gb",
  function() Snacks.picker.git_branches() end,
  { desc = "Git Branches" }
)
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
map(
  "n",
  "<leader>gL",
  function() Snacks.picker.git_log_line() end,
  { desc = "Git Log Line" }
)
map(
  "n",
  "<leader>gs",
  function() Snacks.picker.git_status() end,
  { desc = "Git Status" }
)
map("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
map(
  "n",
  "<leader>gd",
  function() Snacks.picker.git_diff() end,
  { desc = "Git Diff (Hunks)" }
)
map(
  "n",
  "<leader>gf",
  function() Snacks.picker.git_log_file() end,
  { desc = "Git Log File" }
)
map(
  "n",
  "<leader>gi",
  function() Snacks.picker.gh_issue() end,
  { desc = "GitHub Issues (open)" }
)
map(
  "n",
  "<leader>gI",
  function() Snacks.picker.gh_issue { state = "all" } end,
  { desc = "GitHub Issues (all)" }
)
map(
  "n",
  "<leader>gp",
  function() Snacks.picker.gh_pr() end,
  { desc = "GitHub Pull Requests (open)" }
)
map(
  "n",
  "<leader>gP",
  function() Snacks.picker.gh_pr { state = "all" } end,
  { desc = "GitHub Pull Requests (all)" }
)
map("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
map("n", "<leader>uZ", function() Snacks.zen() end, { desc = "Toggle Zen Mode" })
map("n", "<leader>uz", function() Snacks.zen.zoom() end, { desc = "Toggle Zoom" })
map(
  "n",
  "<leader>>",
  function() Snacks.scratch() end,
  { desc = "Toggle Scratch Buffer" }
)
map(
  "n",
  "<leader>S",
  function() Snacks.scratch.select() end,
  { desc = "Select Scratch Buffer" }
)
map(
  "n",
  "<leader>cf",
  function() Snacks.rename.rename_file() end,
  { desc = "Rename File" }
)
map(
  { "n", "v" },
  "<leader>gB",
  function() Snacks.gitbrowse() end,
  { desc = "Git Browse" }
)
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map(
  { "n", "t" },
  "]]",
  function() Snacks.words.jump(vim.v.count1) end,
  { desc = "Next Reference" }
)
map(
  { "n", "t" },
  "[[",
  function() Snacks.words.jump(-vim.v.count1) end,
  { desc = "Prev Reference" }
)
map("n", "<leader>sf", function() Snacks.picker.smart() end, { desc = "Search Files" })
map(
  "n",
  "<leader><space>",
  function() Snacks.picker.smart() end,
  { desc = "Search Files" }
)
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Search Help" })
map(
  "n",
  "<leader>sk",
  function() Snacks.picker.keymaps() end,
  { desc = "Search Keymaps" }
)
map(
  "n",
  "<leader>ss",
  function() Snacks.picker.pickers() end,
  { desc = "Search Select Picker" }
)
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
map(
  "n",
  "<leader>sd",
  function() Snacks.picker.diagnostics() end,
  { desc = "Search Diagnostics" }
)
map(
  "n",
  "<leader>sR",
  function() Snacks.picker.resume() end,
  { desc = "Search Resume" }
)
map(
  "n",
  "<leader>s.",
  function() Snacks.picker.recent() end,
  { desc = "Search Recent Files" }
)
map(
  "n",
  "<leader>sc",
  function() Snacks.picker.commands() end,
  { desc = "Search Commands" }
)
map(
  { "n", "v" },
  "<leader>sw",
  function() Snacks.picker.grep_word() end,
  { desc = "Search current Word" }
)
map(
  "n",
  "<leader>sb",
  function() Snacks.picker.buffers() end,
  { desc = "Search Buffers" }
)
map(
  "n",
  "<leader>,",
  function() Snacks.picker.buffers() end,
  { desc = "Search Buffers" }
)
map(
  "n",
  "<leader>.",
  function()
    Snacks.picker.lines {
      layout = { preset = "dropdown" },
    }
  end,
  { desc = "Fuzzily search in current buffer" }
)
map(
  "n",
  "<leader>s/",
  function() Snacks.picker.grep { buf = true } end,
  { desc = "Search in Open Files" }
)
map(
  "n",
  "<leader>sn",
  function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end,
  { desc = "Search Neovim files" }
)
map(
  "n",
  "<leader>sz",
  function() Snacks.picker.zoxide() end,
  { desc = "Search Zoxide" }
)
map(
  "n",
  "<leader>sp",
  function() Snacks.picker.projects() end,
  { desc = "Search Projects" }
)

return plugin {
  src = "folke/snacks.nvim",
  config = function(opts)
    local snacks = require "snacks"
    snacks.setup(opts)

    snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
    snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
    snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
    snacks.toggle.diagnostics():map "<leader>ud"
    snacks.toggle.line_number():map "<leader>ul"
    snacks.toggle
      .option(
        "conceallevel",
        { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }
      )
      :map "<leader>uc"
    snacks.toggle.treesitter():map "<leader>uT"
    snacks.toggle
      .option("background", { off = "light", on = "dark", name = "Dark Background" })
      :map "<leader>ub"
    snacks.toggle.inlay_hints():map "<leader>uh"
    snacks.toggle.indent():map "<leader>ug"
    snacks.toggle.dim():map "<leader>uD"
    Snacks.toggle
      .new({
        name = "Centered Cursor",
        get = function() return vim.o.scrolloff >= 10 end,
        set = function(state)
          vim.o.scrolloff = state and 99 or 7
          if vim.version().minor >= 13 then vim.o.scrolloffpad = state and 1 or 0 end
        end,
      })
      :map "<leader>uS"
  end,
  opts = {
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
    picker = {
      enabled = true,
      layout = function()
        if vim.o.columns < 120 then return { preset = "vertical", reverse = true } end
        return { preset = "telescope" }
      end,
      sources = {
        smart = {
          filter = { cwd = true },
          matcher = { frecency = true, sort_empty = true },
        },
        zoxide = {
          finder = "files_zoxide",
          format = "file",
          confirm = "load_session",
          win = { preview = { minimal = true } },
        },
        projects = {
          finder = "recent_projects",
          format = "file",
          dev = { "~/Projects" },
          confirm = "load_session",
          patterns = { ".git", "package.json", "Makefile", "Cargo.toml" },
          recent = true,
          matcher = {
            frecency = true,
            sort_empty = true,
            cwd_bonus = false,
          },
          sort = { fields = { "score:desc", "idx" } },
        },
      },
      actions = {
        load_session = function(picker, item)
          picker:close()
          vim.cmd.cd(item.file)
          vim.schedule(function() require("utils.session").restore_session() end)
        end,
      },
    },
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
  },
}
