local utils = require "utils.pack"

utils.add(
  "https://github.com/mason-org/mason.nvim",
  function()
    require("mason").setup {
      ui = { border = "rounded" },
    }
  end
)

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

utils.add("https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", function()
  local registry = require("core.lang_reg").get_all()
  local ensure = {}
  if registry.servers then
    for server, opts in pairs(registry.servers) do
      table.insert(ensure, (opts.mason_name or server))
    end
  end
  if registry.tools then vim.list_extend(ensure, registry.tools) end
  require("mason-tool-installer").setup {
    ensure_installed = ensure,
    run_on_start = true,
  }
end)
