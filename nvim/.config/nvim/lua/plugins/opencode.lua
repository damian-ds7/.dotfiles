return {
  "NickvanDyke/opencode.nvim",
  keys = {
    { "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask opencode" },
    { "<leader>ax", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Execute opencode action…" },
    { "<leader>at", function() require("opencode").toggle() end, mode = { "n", "x" }, desc = "Toggle opencode" },
    { "go", function() return require("opencode").operator "@this " end, expr = true, mode = { "n", "x" }, desc = "Add range to opencode" },
    { "goo", function() return require("opencode").operator "@this " .. "_" end, expr = true, desc = "Add line to opencode" },
    { "<S-C-u>", function() require("opencode").command "session.half.page.up" end, desc = "opencode half page up" },
    { "<S-C-d>", function() require("opencode").command "session.half.page.down" end, desc = "opencode half page down" },
  },
  config = function()
    vim.o.autoread = true

    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then wk.add { { "<leader>a", group = "AI" } } end

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        cmd = "opencode --continue --port",
        enabled = (function()
          local by_name = {}
          local providers = require("opencode.provider").list()
          for _, p in ipairs(providers) do
            by_name[p.name] = p
          end

          for _, name in ipairs { "tmux", "snacks" } do
            local provider = by_name[name]
            if provider and provider.health() == true then return name end
          end
          return false
        end)(),
        tmux = { options = "-h -p 33" },
        snacks = { win = { enter = true } },
      },
      events = {
        enabled = true,
        reload = true,
        permissions = { enabled = false },
      },
    }
  end,
}
