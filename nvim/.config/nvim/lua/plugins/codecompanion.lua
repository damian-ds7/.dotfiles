local utils = require "utils.pack"
local get_dims = require("utils.float").floating_window_dims

utils.ensure(utils.gh "nvim-lua/plenary.nvim")
utils.ensure(utils.gh "nvim-treesitter/nvim-treesitter")

utils.add({ src = utils.gh "olimorris/codecompanion.nvim", version = vim.version.range "^19.0.0" }, function()
  vim.cmd.packadd "plenary.nvim"
  vim.cmd.packadd "nvim-treesitter"
  local w, h, c, r = get_dims()
  require("codecompanion").setup {
    display = {
      chat = {
        window = {
          border = "rounded",
          opts = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            foldcolumn = "0",
            statuscolumn = "",
          },
        },
        floating_window = {
          border = "rounded",
        },
      },
      input = {
        window = {
          border = "rounded",
        },
      },
      diff = {
        window = {
          border = "rounded",
          width = w,
          height = h,
          col = c,
          row = r,
        },
      },
      cli = {
        window = {
          opts = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            foldcolumn = "0",
            statuscolumn = "",
          },
        },
      },
    },
    interactions = {
      chat = {
        adapter = "gemini_cli",
      },
      cli = {
        agent = "gemini_cli",
        agents = {
          gemini_cli = {
            cmd = "gemini",
            args = {},
            description = "Gemini CLI",
            provider = "terminal",
          },
        },
      },
      inline = {
        adapter = "gemini_cli",
      },
    },
    adapters = {
      acp = {
        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
            },
          })
        end,
      },
    },
    triggers = {
      acp_slash_commands = "\\",
      editor_context = "#",
      slash_commands = "/",
      tools = "@",
    },
  }
  vim.cmd [[cab cc CodeCompanion]]
end, "later")

local map = vim.keymap.set

local function toggle_chat(layout)
  local chat = require("codecompanion.interactions.chat").last_chat()
  if chat and chat.ui:is_visible() then
    local config = vim.api.nvim_win_get_config(chat.ui.winnr)
    local is_float = config.relative ~= ""
    if (layout == "float" and not is_float) or (layout == "vertical" and is_float) then chat.ui:hide() end
  end

  if layout == "vertical" then
    require("codecompanion").toggle {
      window_opts = {
        layout = "vertical",
        position = "right",
        width = 0.4,
      },
    }
  else
    local w, h, c, r = get_dims()
    require("codecompanion").toggle {
      window_opts = {
        layout = "float",
        relative = "editor",
        width = w,
        height = h,
        col = c,
        row = r,
      },
    }
  end
end

map("n", "<leader>at", function()
  local cli = require "codecompanion.interactions.cli"
  if cli and cli.is_visible() then
    require("codecompanion").toggle()
  else
    require("codecompanion").cli {
      layout = "vertical",
      position = "right",
      width = 0.4,
    }
  end
end, { desc = "CodeCompanion: Toggle CLI" })

map("n", "<leader>aa", "<cmd>CodeCompanionCLI! Ask<cr>", { desc = "CodeCompanion: CLI Ask" })
map("v", "<leader>aa", ":CodeCompanionChat Add<cr>", { desc = "CodeCompanion: Chat Add" })
map("n", "<leader>ac", function() toggle_chat "vertical" end, { desc = "CodeCompanion: Toggle Chat (Split)" })
map("n", "<leader>aC", function() toggle_chat "float" end, { desc = "CodeCompanion: Toggle Chat (Float)" })
map("n", "<leader>ap", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion: Actions Palette" })
