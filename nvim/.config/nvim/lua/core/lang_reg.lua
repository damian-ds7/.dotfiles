---@class LangConfig
---@field servers? table<string, vim.lsp.Config>
---@field tools? string[]
---@field treesitter? string[]
---@field formatters_by_ft? table<string, string[]>
---@field formatters? table<string, table<string, string[]>>
---@field dap? { adapters?: table<string, any>, configurations?: table<string, any> }
---@field neotest_adapters? table<string, any>

---@class LangRestistry : LangConfig
local M = {
  servers = {},
  tools = {},
  treesitter = {},
  formatters_by_ft = {},
  formatters = {},
  dap = {
    adapters = {},
    configurations = {},
  },
  neotest_adapters = {},
}

---Register a language configuration.
---@param lang LangConfig The configuration to register.
function M.register(lang)
  if lang.servers then
    M.servers = vim.tbl_deep_extend("force", M.servers, lang.servers)
  end

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

  if lang.formatters_by_ft then
    M.formatters_by_ft =
      vim.tbl_deep_extend("force", M.formatters_by_ft, lang.formatters_by_ft)
  end

  if lang.formatters then
    M.formatters = vim.tbl_deep_extend("force", M.formatters, lang.formatters)
  end

  if lang.dap then
    if lang.dap.adapters then
      M.dap.adapters = vim.tbl_deep_extend("force", M.dap.adapters, lang.dap.adapters)
    end
    if lang.dap.configurations then
      M.dap.configurations =
        vim.tbl_deep_extend("force", M.dap.configurations, lang.dap.configurations)
    end
  end

  if lang.neotest_adapters then
    M.neotest_adapters =
      vim.tbl_deep_extend("force", M.neotest_adapters, lang.neotest_adapters)
  end
end

---Get all registered language configurations.
---@return LangConfig
function M.get_all() return M end

return M
