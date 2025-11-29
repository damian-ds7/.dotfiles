return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local project_actions = require("telescope._extensions.project.actions")

    require("telescope").setup({
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

    require("telescope").load_extension("project")
  end,
}
