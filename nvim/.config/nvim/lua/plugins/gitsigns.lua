local utils = require "utils.pack"

local function config()
  require("gitsigns").setup {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    preview_config = {
      border = "rounded",
    },
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 50,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    current_line_blame = true,
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns
      local wk = require "which-key"
      local icon, hl = MiniIcons.get("filetype", "git")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        wk.add { l, r, desc = desc, icon = { icon = icon, hl = hl } }
      end

      wk.add { "gh", group = "Hunks", icon = { icon = icon, hl = hl } }

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          gs.nav_hunk "next"
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          gs.nav_hunk "prev"
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk "last" end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk "first" end, "First Hunk")
      map({ "n", "x" }, "ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "x" }, "ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "ghb", function() gs.blame_line { full = true } end, "Blame Line")
      map("n", "ghB", function() gs.blame() end, "Blame Buffer")
      map("n", "ghd", gs.diffthis, "Diff This")
      map("n", "ghD", function() gs.diffthis "~" end, "Diff This ~")
      map({ "o", "x" }, "gih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

      local snacks = require "snacks"
      snacks.toggle
        .new({
          name = "Git Blame Line",
          get = function() return require("gitsigns.config").config.current_line_blame end,
          set = function() gs.toggle_current_line_blame() end,
        })
        :map "<leader>ub"
    end,
  }
end

utils.add(utils.gh "lewis6991/gitsigns.nvim", config, "event:BufReadPost,BufWritePost,BufNewFile")
