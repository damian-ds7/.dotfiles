return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  config = function()
    local modes = { "n", "v", "t" }
    local mappings = {
      ["<C-h>"] = "TmuxNavigateLeft",
      ["<C-j>"] = "TmuxNavigateDown",
      ["<C-k>"] = "TmuxNavigateUp",
      ["<C-l>"] = "TmuxNavigateRight",
      ["<C-\\>"] = "TmuxNavigatePrevious",
    }

    for key, command in pairs(mappings) do
      vim.keymap.set(modes, key, "<cmd>" .. command .. "<cr>", {
        desc = "Tmux Navigation: " .. command,
        silent = true,
      })
    end
  end,
}
