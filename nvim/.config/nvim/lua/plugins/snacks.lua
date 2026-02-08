return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          actions = {
            explorer_paste = function(picker, item) --[[Override]]
              local Tree = require("snacks.explorer.tree")
              local files = vim.split(vim.fn.getreg(vim.v.register or "+") or "", "\n", { plain = true })
              files = vim.tbl_filter(function(file)
                -- NOTE: Use `vim.uv.fs_stat` instead of `vim.fn.filereadable`
                return file ~= "" and vim.uv.fs_stat(file) ~= nil
              end, files)
              if #files == 0 then
                return Snacks.notify.warn(
                  ("The `%s` register does not contain any files"):format(vim.v.register or "+")
                )
              end
              local dir = picker:dir()
              -- NOTE: Prefer parent when directory is closed
              if item.dir and not item.open then
                dir = vim.fs.dirname(dir)
              end
              -- NOTE: Replace `Snacks.picker.util.copy`
              for _, file in ipairs(files) do
                -- BUG: Prevent pasting inside itself
                if file == dir then
                  Snacks.notify.warn(string.format("Skip recursive copy: %s", file))
                else
                  local dst = vim.fs.joinpath(dir, vim.fn.fnamemodify(file, ":t"))
                  local dst_unique = dst
                  local count = 0
                  while vim.uv.fs_stat(dst_unique) do
                    count = count + 1
                    dst_unique = string.format("%s (copy %d)", dst, count)
                  end
                  Snacks.picker.util.copy_path(file, dst_unique)
                end
              end
              Tree:refresh(dir)
              Tree:open(dir)
              picker:update({ target = dir })
            end,
          },
          hidden = true,
        },
        files = { hidden = true },
        grep = { hidden = true },
      },
    },
  },
  keys = {
    -- git
    {
      "<leader>gb",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Log",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gS",
      function()
        Snacks.picker.git_stash()
      end,
      desc = "Git Stash",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },
    {
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Log File",
    },
    -- gh
    {
      "<leader>gi",
      function()
        Snacks.picker.gh_issue()
      end,
      desc = "GitHub Issues (open)",
    },
    {
      "<leader>gI",
      function()
        Snacks.picker.gh_issue({ state = "all" })
      end,
      desc = "GitHub Issues (all)",
    },
    {
      "<leader>gp",
      function()
        Snacks.picker.gh_pr()
      end,
      desc = "GitHub Pull Requests (open)",
    },
    {
      "<leader>gP",
      function()
        Snacks.picker.gh_pr({ state = "all" })
      end,
      desc = "GitHub Pull Requests (all)",
    },
    -- Other
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
  },
}
