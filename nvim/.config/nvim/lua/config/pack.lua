local pack = require "utils.pack"
local lang_reg = require "core.lang_reg"

--- Wrap a plugin spec for declarative registration.
---@generic T : PluginSpec
---@param spec T Plugin definition.
---@return { plugin: T }
_G.plugin = function(spec) return { plugin = spec } end

--- Wrap a language config for declarative registration.
---@generic T : LangConfig
---@param spec T Language definition.
---@return { lang: T }
_G.lang = function(spec) return { lang = spec } end

---Process a returned configuration item (plugin or lang).
---@param item any
local function process(item)
  if not item or type(item) ~= "table" then return end

  if item.plugin then
    pack.handle_spec_table(item.plugin)
  elseif item.lang then
    lang_reg.register(item.lang)
  elseif #item > 0 then
    for _, i in ipairs(item) do
      process(i)
    end
  end
end

local base = vim.fn.stdpath "config" .. "/lua/plugins"

for _, path in ipairs(vim.fn.globpath(base, "**/*.lua", false, true)) do
  local rel = vim.fs.relpath(base, path)
  if rel and not rel:match "^_" and not rel:match "/_" then
    local mod = require("plugins." .. rel:gsub("/", "."):gsub("%.lua$", ""))
    process(mod)
  end
end

pack.sync()
