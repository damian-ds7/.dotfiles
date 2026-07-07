---@class LangConfig
---@field filetype?          string|string[]
---@field eager?             boolean
---@field servers?           table<string, vim.lsp.Config>
---@field tools?             string[]
---@field treesitter?        string[]
---@field formatters_by_ft?  table<string, string[]>
---@field formatters?        table<string, table<string, any>>
---@field dap?               { adapters?: table<string, any>, configurations?: table<string, any> }
---@field neotest_adapters?  table<string, any>

---@class LazyFtEntry
---@field mason_pkgs string[]
---@field parsers    string[]

local M = {}

local servers = {}

local eager_mason_pkgs = {}
local eager_parsers = {}

---@type table<string, LazyFtEntry>
local lazy_by_ft = {}

local formatters_by_ft = {}
local formatters = {}
local dap = { adapters = {}, configurations = {} }
local neotest_adapters = {}

local _config = {
  formatters_by_ft = formatters_by_ft,
  formatters = formatters,
  dap = dap,
  neotest_adapters = neotest_adapters,
}

---@param basename string  e.g. "c-cpp", "lua"
---@return string[]
local function infer_filetypes(basename)
  return vim.split(basename, "-", { plain = true })
end

---Register a language configuration.
---@param lang LangConfig
---@param source_basename? string  basename of the langs/*.lua file, e.g. "c-cpp"
function M.register(lang, source_basename)
  if lang.formatters_by_ft then
    for ft, fmts in pairs(lang.formatters_by_ft) do
      formatters_by_ft[ft] = fmts
    end
  end

  if lang.formatters then
    for name, opts in pairs(lang.formatters) do
      formatters[name] = opts
    end
  end

  if lang.dap then
    for k, v in pairs(lang.dap.adapters or {}) do
      dap.adapters[k] = v
    end
    for k, v in pairs(lang.dap.configurations or {}) do
      dap.configurations[k] = v
    end
  end

  if lang.neotest_adapters then
    for k, v in pairs(lang.neotest_adapters) do
      neotest_adapters[k] = v
    end
  end

  local mason_pkgs = {}
  if lang.servers then
    for name, opts in pairs(lang.servers) do
      table.insert(mason_pkgs, opts.mason_name or name)
      local lsp_opts = vim.tbl_extend("force", {}, opts)
      lsp_opts.mason_name = nil
      servers[name] = vim.tbl_deep_extend("force", servers[name] or {}, lsp_opts)
    end
  end

  if lang.tools then vim.list_extend(mason_pkgs, lang.tools) end

  local parsers = lang.treesitter or {}

  if lang.eager or not source_basename then
    vim.list_extend(eager_mason_pkgs, mason_pkgs)
    vim.list_extend(eager_parsers, parsers)
    return
  end

  local fts = lang.filetype
  if type(fts) == "string" then
    fts = { fts }
  elseif not fts then
    fts = infer_filetypes(source_basename)
  end

  for _, ft in ipairs(fts) do
    if not lazy_by_ft[ft] then lazy_by_ft[ft] = { mason_pkgs = {}, parsers = {} } end
    vim.list_extend(lazy_by_ft[ft].mason_pkgs, mason_pkgs)
    vim.list_extend(lazy_by_ft[ft].parsers, parsers)
  end
end

function M.get_servers() return servers end

function M.get_eager_mason_pkgs() return eager_mason_pkgs end

function M.get_eager_parsers() return eager_parsers end

---@param ft string
---@return LazyFtEntry?
function M.get_lazy_entry(ft) return lazy_by_ft[ft] end

---@return string[]
function M.get_lazy_filetypes() return vim.tbl_keys(lazy_by_ft) end

---Backward compat for conform, dap, neotest consumers.
function M.get_all() return _config end

return M
