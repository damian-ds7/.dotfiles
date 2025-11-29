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
  end,
}
