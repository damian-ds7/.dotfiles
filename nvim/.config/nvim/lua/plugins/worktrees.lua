return plugin {
  src = "Juksuu/worktrees.nvim",
  lazy = true,
  opts = {
    switch_file_command = false,
    swap_current_buffer = true,
    hooks = {
      on_before_switch = function(old_path, _, _)
        require("utils.session").write_session(old_path)

        vim.cmd "silent! %bwipeout!"
        for _, client in ipairs(vim.lsp.get_clients()) do
          client:stop()
        end
      end,
      on_switch = function(_, _, _)
        require("utils.session").reset()
        require("utils.session").restore_session()
      end,
      on_before_remove = function(path)
        if path ~= vim.loop.cwd() or vim.v.this_session == "" then return end

        require("mini.sessions").delete()
        vim.v.this_session = ""
      end,
    },
  },
  keys = {
    {
      "n",
      "<leader>gws",
      function() Snacks.picker.worktrees() end,
      desc = "Switch Git Worktree",
    },
    {
      "n",
      "<leader>gwc",
      function() Snacks.picker.worktrees_new() end,
      desc = "Create Git Worktree",
    },
    {
      "n",
      "<leader>gwd",
      function() Snacks.picker.worktrees_remove() end,
      desc = "Delete Git Worktree",
    },
  },
  config = function(opts)
    require("worktrees").setup(opts)

    local ok, wk = pcall(require, "which-key")
    if ok then wk.add { "<leader>gw", group = "Git Worktrees" } end

    vim.api.nvim_create_user_command(
      "WorktreePick",
      function() Snacks.picker.worktrees() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "WorktreeCreatePick",
      function() Snacks.picker.worktrees_new() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "WorktreeDeletePick",
      function() Snacks.picker.worktrees_remove() end,
      {}
    )
  end,
}
