return {
  "NickvanDyke/opencode.nvim",
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        cmd = "opencode --continue --port",
        enabled = (function()
          local by_name = {}
          for _, p in ipairs(require("opencode.provider").list()) do
            by_name[p.name] = p
          end

          for _, name in ipairs({ "tmux", "snacks" }) do
            local provider = by_name[name]
            if provider then
              local ok = provider.health()
              if ok == true then
                return name
              end
            end
          end

          return false
        end)(),
        tmux = {
          options = "-h -p 33",
        },
        snacks = {
          win = {
            enter = true,
          },
        },
      },
      events = {
        enabled = true,
        reload = true,
        permissions = {
          enabled = false,
        },
      },
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    local wk = require("which-key")
    wk.add({
      { "<leader>a", group = "AI" },
    })

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<leader>aa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ax", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<leader>at", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { expr = true, desc = "Add range to opencode" })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { expr = true, desc = "Add line to opencode" })

    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "opencode half page up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "opencode half page down" })
  end,
}
