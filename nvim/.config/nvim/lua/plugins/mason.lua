return {
  plugin {
    src = "mason-org/mason.nvim",
    opts = {
      ui = { border = "rounded" },
    },
    keys = {
      { "n", "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },
  plugin {
    src = "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      local reg = require "core.lang_reg"
      local misc = require "mini.misc"

      require("mason-tool-installer").setup {
        ensure_installed = reg.get_eager_mason_pkgs(),
        run_on_start = true,
      }

      for _, ft in ipairs(reg.get_lazy_filetypes()) do
        misc.safely("filetype:" .. ft, function()
          local entry = reg.get_lazy_entry(ft)
          if not entry then return end
          local mason_reg = require "mason-registry"
          for _, pkg_name in ipairs(entry.mason_pkgs) do
            local ok, pkg = pcall(mason_reg.get_package, pkg_name)
            if ok and not pkg:is_installed() then pkg:install() end
          end
        end)
      end
    end,
  },
}
