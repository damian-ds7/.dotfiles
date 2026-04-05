local M = {
  servers = {},
  tools = {},
  treesitter = {},
  formatters = {},
  dap = {
    adapters = {},
    configurations = {},
  },
  neotest_adapters = {},
}

function M.register(lang)
  if lang.servers then M.servers = vim.tbl_deep_extend("force", M.servers, lang.servers) end

  if lang.tools then
    for _, tool in ipairs(lang.tools) do
      table.insert(M.tools, tool)
    end
  end

  if lang.treesitter then
    for _, parser in ipairs(lang.treesitter) do
      table.insert(M.treesitter, parser)
    end
  end

  if lang.formatters then M.formatters = vim.tbl_deep_extend("force", M.formatters, lang.formatters) end

  if lang.dap then
    if lang.dap.adapters then M.dap.adapters = vim.tbl_deep_extend("force", M.dap.adapters, lang.dap.adapters) end
    if lang.dap.configurations then
      M.dap.configurations = vim.tbl_deep_extend("force", M.dap.configurations, lang.dap.configurations)
    end
  end

  if lang.neotest_adapters then
    M.neotest_adapters = vim.tbl_deep_extend("force", M.neotest_adapters, lang.neotest_adapters)
  end
end

function M.get_all() return M end

return M
