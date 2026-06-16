vim.filetype.add {
  extension = {
    ipynb = "ipynb",
  },
}

return plugin {
  src = "sheng-tse/jupynvim",
  filetype = "ipynb",
  pack_changed = {
    kind = "install",
    action = function(data)
      local install = loadfile(data.path .. "/lua/jupynvim/install.lua")()
      install.run { dir = data.path }
    end,
  },
  config = function(opts)
    local ok, wk = pcall(require, "which-key")
    local icon, hl = MiniIcons.get("filetype", "python")

    if ok then
      wk.add { "<leader>j", group = "Jupynvim", icon = { icon = icon, hl = hl } }
    end
    require("jupynvim").setup(opts)

    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype == "ipynb" then vim.cmd "edit" end
    end)
  end,
  opts = {
    log_level = "info",
    image_renderer = "kitty", -- "placeholder", "kitty", or "chafa"
    -- disable_default_keymaps = true,
    keymaps = {
      run_advance = "<leader>jr",
      run_all = "<leader>jR",
      run_above = "<leader>jA",
      run_below = "<leader>jB",
      add_above = "<leader>ja",
      add_below = "<leader>jb",
      delete_cell = "<leader>jd",
      move_up = "<leader>jk",
      move_down = "<leader>jj",
      to_markdown = "<leader>jm",
      to_code = "<leader>jy",
      pick_kernel = "<leader>jK",
      start_kernel = "<leader>js",
      stop_kernel = "<leader>jS",
      interrupt_kernel = "<leader>ji",
      restart_kernel = "<leader>jx",
      clear_output = "<leader>jc",
      clear_all = "<leader>jC",
      next_cell = "]c",
      prev_cell = "[c",
      next_image = "]i",
      prev_image = "[i",
      enter_output_dn = "<C-j>",
      enter_output_up = "<C-k>",
      save_image = "<leader>jI",
      delete_image = "<leader>jD",
      refresh = "<leader>jL",
      open_link = "gx",
    },
    explorer_keys = {},
    terminal_keys = {},
    terminal_right_keys = {},
    pick_keys = {
      files = {},
      grep = {},
    },
  },
}
