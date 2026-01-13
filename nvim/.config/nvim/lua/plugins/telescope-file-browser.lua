return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      extensions = {
        file_browser = {
          hidden = true,
          follow_symlinks = true,
        },
      },
    })

    telescope.load_extension("file_browser")

    local wk = require("which-key")
    wk.add({
      { "<leader>k", group = "projects/files" },
    })

    vim.keymap.set("n", "<leader>ko", function()
      telescope.extensions.file_browser.file_browser({
        path = vim.fn.getcwd(),
        cwd = vim.fn.getcwd(),
        hidden = true,
        grouped = true,
        initial_mode = "insert",
      })
    end, { desc = "Change directory with file browser" })

    vim.keymap.set("n", "<leader>kO", function()
      require("telescope").extensions.file_browser.file_browser({
        path = vim.fn.expand("~"),
        cwd = vim.fn.expand("~"),
        hidden = true,
        grouped = true,
        initial_mode = "insert",
      })
    end, { desc = "Change directory from home" })
  end,
}
