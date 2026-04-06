local utils = require "utils.pack"

local config = function()
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
end

utils.add(utils.gh "christoomey/vim-tmux-navigator", config)
