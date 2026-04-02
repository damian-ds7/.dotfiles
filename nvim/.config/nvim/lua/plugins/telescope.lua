local utils = require "utils.pack"

utils.ensure "https://github.com/nvim-lua/plenary.nvim"
utils.ensure "https://github.com/nvim-telescope/telescope-ui-select.nvim"
utils.ensure "https://github.com/nvim-telescope/telescope-fzf-native.nvim"

utils.add("https://github.com/nvim-telescope/telescope.nvim", function()
  vim.cmd.packadd "plenary.nvim"
  vim.cmd.packadd "telescope-ui-select.nvim"
  if vim.fn.executable "make" == 1 then vim.cmd.packadd "telescope-fzf-native.nvim" end

  require("telescope").setup {
    extensions = {
      ["ui-select"] = { require("telescope.themes").get_dropdown() },
    },
    defaults = {
      mappings = {
        n = {
          ["q"] = require("telescope.actions").close,
        },
      },
    },
  }
  pcall(require("telescope").load_extension, "fzf")
  pcall(require("telescope").load_extension, "ui-select")
end)

utils.on_pack_changed("telescope-fzf-native.nvim", "install", function(data)
  if not data.active then vim.cmd.packadd "telescope-fzf-native.nvim" end
  vim.fn.system { "make", "-C", data.spec.dir }
end)

vim.keymap.set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Search Files" })
vim.keymap.set("n", "<leader><space>", "<cmd>Telescope find_files<cr>", { desc = "Search Files" })
vim.keymap.set("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Search Help" })
vim.keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Search Keymaps" })
vim.keymap.set("n", "<leader>ss", "<cmd>Telescope builtin<cr>", { desc = "Search Select Telescope" })
vim.keymap.set("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics<cr>", { desc = "Search Diagnostics" })
vim.keymap.set("n", "<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Search Resume" })
vim.keymap.set("n", "<leader>s.", "<cmd>Telescope oldfiles<cr>", { desc = "Search Recent Files" })
vim.keymap.set("n", "<leader>sc", "<cmd>Telescope commands<cr>", { desc = "Search Commands" })
vim.keymap.set({ "n", "v" }, "<leader>sw", "<cmd>Telescope grep_string<cr>", { desc = "Search current Word" })
vim.keymap.set(
  "n",
  "<leader>sb",
  function() require("telescope.builtin").buffers { sort_mru = true, sort_lastused = true } end,
  { desc = "Search buffers" }
)
vim.keymap.set(
  "n",
  "<leader>.",
  function()
    require("telescope.builtin").current_buffer_fuzzy_find(
      require("telescope.themes").get_dropdown { previewer = false }
    )
  end,
  { desc = "Fuzzily search in current buffer" }
)
vim.keymap.set(
  "n",
  "<leader>s/",
  function() require("telescope.builtin").live_grep { grep_open_files = true, prompt_title = "Live Grep in Open Files" } end,
  { desc = "Search in Open Files" }
)
vim.keymap.set(
  "n",
  "<leader>sn",
  function() require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config" } end,
  { desc = "Search Neovim files" }
)
