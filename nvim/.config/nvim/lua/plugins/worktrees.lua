return plugin {
  src = "afonsofrancof/worktrees.nvim",
  lazy = true,
  opts = {
    base_path = "..",
    path_template = "{branch}",
    on_create = function(_) require("utils.session").restore_session() end,
    on_delete = function(_) require("utils.session").restore_session() end,
    on_switch = function(_, _) require("utils.session").restore_session() end,
  },
}
