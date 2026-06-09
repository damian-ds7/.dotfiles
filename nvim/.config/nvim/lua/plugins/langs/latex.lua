return {
  lang {
    servers = {
      texlab = {
        settings = {
          texlab = {
            chktex = { onEdit = true, onOpenAndSave = true },
            diagnosticsDelay = 300,
          },
        },
      },
    },
    tools = { "tex-fmt", "texlab" },
    treesitter = { "latex" },
    formatters_by_ft = {
      tex = { "tex-fmt" },
    },
    formatters = {
      ["tex-fmt"] = { append_args = { "--wraplen", "80" } },
    },
  },
  plugin {
    -- System packages: zathura, zathura-pdf-poppler, chktex, latexmk
    src = "lervag/vimtex",
    config = function() vim.g.vimtex_view_method = "zathura" end,
  },
}
