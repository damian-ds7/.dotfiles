return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  dependencies = { { "nvim-mini/mini.icons", opts = {} }, { "benomahony/oil-git.nvim" } },
  cmd = "Oil",
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _) return name == ".." or name == ".git" end,
    },
    win_options = {
      wrap = true,
    },
    float = {
      padding = 2,
      max_width = 0.6,
      max_height = 0,
      border = "rounded",
    },
    keymaps = {
      ["g?"] = { "actions.show_help", desc = "Help" },
      ["<CR>"] = { "actions.select", desc = "Open" },
      ["L"] = { "actions.select" },
      ["<M-s>"] = { "actions.select", opts = { vertical = true }, desc = "V-Split" },
      ["<C-s>"] = false,
      ["<M-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Split" },
      ["<C-h>"] = false,
      ["<M-t>"] = { "actions.select", opts = { tab = true }, desc = "New Tab" },
      ["<C-t>"] = false,
      ["<M-l>"] = { "actions.refresh", desc = "Refresh" },
      ["<C-l>"] = false,
      ["<C-p>"] = { "actions.preview", desc = "Preview" },
      ["<C-c>"] = { "actions.close", desc = "Close" },
      ["<Esc><Esc>"] = { "actions.close", desc = "Close" },
      ["-"] = { "actions.parent", desc = "Up Dir" },
      ["H"] = { "actions.parent" },
      ["_"] = { "actions.open_cwd", desc = "To CWD" },
      ["`"] = { "actions.cd", desc = "Change Dir" },
      ["g~"] = { "actions.cd", opts = { scope = "tab" }, desc = "Tab CD" },
      ["gs"] = { "actions.change_sort", desc = "Sort" },
      ["gx"] = { "actions.open_external", desc = "External" },
      ["g."] = { "actions.toggle_hidden", desc = "Hidden" },
      ["g\\"] = { "actions.toggle_trash", desc = "Trash" },
    },
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    { "<leader>E", function() require("oil").toggle_float() end, desc = "Open parent directory" },
    {
      "<leader>e",
      function()
        local root = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
        require("oil").toggle_float(root)
      end,
      desc = "Open Project Root",
    },
  },
}
