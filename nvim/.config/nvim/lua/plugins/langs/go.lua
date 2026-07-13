vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local listchars = vim.opt.listchars:get()
    listchars.tab = "  "
    vim.opt_local.listchars = listchars
  end,
})

return {
  lang {
    servers = {
      gopls = {
        settings = {
          gopls = {
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
            },
            semanticTokens = true,
          },
        },
        on_attach = function(client, _)
          -- Workaround for semantic tokens if the server doesn't report them correctly
          if not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            if not semantic then return end
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              range = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
            }
          end
        end,
      },
      golangci_lint_ls = {
        mason_name = "golangci-lint-langserver",
      },
    },
    tools = { "goimports", "golines", "golangci-lint", "delve" },
    treesitter = { "go", "gomod", "gosum" },
    formatters_by_ft = {
      go = { "goimports", "golines" },
    },
    neotest_adapters = {
      ["neotest-golang"] = {
        runner = "gotestsum",
        dap_go_enabled = true,
      },
    },
  },
  plugin {
    src = "leoluz/nvim-dap-go",
    filetype = "go",
    config = function()
      pcall(vim.cmd.packadd, "nvim-dap")
      require("dap-go").setup()
    end,
  },
  plugin {
    src = "fredrikaverpil/neotest-golang",
    filetype = "go",
    version = vim.version.range "2.*",
    pack_changed = {
      kind = "install",
      action = function()
        vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
      end,
    },
  },
}
