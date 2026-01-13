return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local project_actions = require("telescope._extensions.project.actions")

    telescope.setup({
      extensions = {
        project = {
          base_dirs = {
            { "~/Projects", max_depth = 3 },
          },
          display_type = "full",
          on_project_selected = function(prompt_bufnr)
            project_actions.change_working_directory(prompt_bufnr, false)
            Snacks.explorer()
          end,
        },
      },
    })

    telescope.load_extension("project")

    local wk = require("which-key")
    wk.add({
      { "<leader>k", group = "projects/files" },
    })

    vim.keymap.set("n", "<leader>kp", function()
      telescope.extensions.project.project({ display_type = "full" })
    end, { desc = "Open project picker" })
  end,
}
