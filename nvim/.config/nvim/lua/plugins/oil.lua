local utils = require "utils.pack"

utils.ensure(utils.gh "benomahony/oil-git.nvim")

utils.add(utils.gh "stevearc/oil.nvim", function()
  vim.cmd.packadd "oil-git.nvim"
  require("oil").setup {
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
  }
end)

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "(Oil) Open parent directory" })
vim.keymap.set("n", "<leader>e", function() require("oil").toggle_float() end, { desc = "(Oil) Open parent directory" })
vim.keymap.set("n", "<leader>E", function()
  local root = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
  require("oil").toggle_float(root)
end, { desc = "(Oil) Open Project Root" })

local last_oil_path = nil

local function open_oil_float(path)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "oil" then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= "" then
        vim.api.nvim_set_current_win(win)
        vim.cmd("Oil " .. vim.fn.fnameescape(path))
        return
      end
    end
  end

  vim.cmd("Oil --float " .. vim.fn.fnameescape(path))
end

local function prompt_and_open()
  vim.ui.input({
    prompt = "Oil path: ",
    completion = "dir",
  }, function(input)
    local target = (input and input ~= "") and input or vim.fn.getcwd()
    last_oil_path = target
    open_oil_float(target)
  end)
end

vim.keymap.set("n", "<leader>o", prompt_and_open, { desc = "(Oil) Open location" })

vim.keymap.set("n", "<leader>O", function()
  if last_oil_path then
    open_oil_float(last_oil_path)
  else
    prompt_and_open()
  end
end, { desc = "(Oil) Reopen last" })
