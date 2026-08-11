local get_dims = require("utils.float").floating_window_dims()

local function toggle_chat(layout)
  local chat = require("codecompanion.interactions.chat").last_chat()
  if chat and chat.ui:is_visible() then
    local config = vim.api.nvim_win_get_config(chat.ui.winnr)
    local is_float = config.relative ~= ""
    if (layout == "float" and not is_float) or (layout == "vertical" and is_float) then
      chat.ui:hide()
    end
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

return plugin {
  src = "olimorris/codecompanion.nvim",
  version = vim.version.range "^19.0.0",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  lazy = true,
  config = function(opts)
    require("codecompanion").setup(opts)
    vim.cmd [[cab cc CodeCompanion]]
  end,
  opts = {
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
      cli = {
        agent = "claude_code",
        agents = {
          antigravity_cli = {
            cmd = "agy",
            args = {},
            description = "Antigravity CLI",
            provider = "terminal",
          },
          claude_code = {
            cmd = "claude",
            args = {},
            description = "Claude Code",
            provider = "terminal",
          },
        },
      },
    },
    triggers = {
      acp_slash_commands = "\\",
      editor_context = "#",
      slash_commands = "/",
      tools = "@",
    },
  },
  keys = {
    {
      "n",
      "<leader>at",
      function()
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
      end,
      desc = "CodeCompanion: Toggle CLI",
    },
    {
      "n",
      "<leader>aa",
      "<cmd>CodeCompanionCLI! Ask<cr>",
      desc = "CodeCompanion: CLI Ask",
    },
    {
      "v",
      "<leader>aa",
      ":CodeCompanionChat Add<cr>",
      desc = "CodeCompanion: Chat Add",
    },
    {
      "n",
      "<leader>ac",
      function() toggle_chat "vertical" end,
      desc = "CodeCompanion: Toggle Chat (Split)",
    },
    {
      "n",
      "<leader>aC",
      function() toggle_chat "float" end,
      desc = "CodeCompanion: Toggle Chat (Float)",
    },
    {
      "n",
      "<leader>ap",
      "<cmd>CodeCompanionActions<cr>",
      desc = "CodeCompanion: Actions Palette",
    },
  },
}
