return {
  "mfussenegger/nvim-lint",
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = { ensure_installed = { "golangci-lint" } },
    },
  },
  opts = {
    linters_by_ft = {
      go = { "golangcilint" },
    },
    linters = {
      golangcilint = {
        args = {
          "run",
          "--output.json.path=stdout",
          "--show-stats=false",
          "--output.text.print-issued-lines=false",
          "--output.text.print-linter-name=false",
          function()
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
          end,
        },
      },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    for name, config in pairs(opts.linters or {}) do
      for key, value in pairs(config) do
        lint.linters[name][key] = value
      end
    end

    lint.linters.golangcilint.ignore_exitcode = true

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
