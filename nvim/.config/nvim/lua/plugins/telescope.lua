return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search Files" },
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Search Files" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search Help" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search Keymaps" },
    { "<leader>ss", "<cmd>Telescope builtin<cr>", desc = "Search Select Telescope" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Search Diagnostics" },
    { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Search Resume" },
    { "<leader>s.", "<cmd>Telescope oldfiles<cr>", desc = "Search Recent Files" },
    { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Search Commands" },

    { "<leader>sw", "<cmd>Telescope grep_string<cr>", mode = { "n", "v" }, desc = "Search current Word" },

    {
      "<leader>sb",
      function() require("telescope.builtin").buffers { sort_mru = true, sort_lastused = true } end,
      desc = "Search buffers",
    },
    {
      "<leader>.",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown { previewer = false }
        )
      end,
      desc = "Fuzzily search in current buffer",
    },
    {
      "<leader>s/",
      function()
        require("telescope.builtin").live_grep { grep_open_files = true, prompt_title = "Live Grep in Open Files" }
      end,
      desc = "Search in Open Files",
    },
    {
      "<leader>sn",
      function() require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config" } end,
      desc = "Search Neovim files",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function() return vim.fn.executable "make" == 1 end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
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
  end,
}
