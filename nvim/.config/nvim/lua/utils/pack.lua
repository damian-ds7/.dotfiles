---@diagnostic disable: unused-function
---@alias PackSpec string | vim.pack.Spec

---@alias PackChangedKind "install" | "update" | "delete"

---@class PackHook
---@field kind PackChangedKind | table<PackChangedKind>
---@field action string|fun(data: any)

---@class PluginSpec
---@field src string
---@field name? string
---@field version? vim.VersionRange
---@field lazy? boolean
---@field event? string|string[]
---@field filetype? string|string[]
---@field opts? table
---@field config? fun(opts?: table)
---@field dependencies? PackSpec|PackSpec[]
---@field pack_changed? PackHook|PackHook[]
---@field vscode? boolean

---@class PackEntry
---@field spec PackSpec
---@field name string
---@field trigger string
---@field config fun()
---@field download_only? boolean

---@type PackEntry[]
local plugins = {}

local M = {}

local pack_changed_group = vim.api.nvim_create_augroup("pack-events", {
  clear = false,
})

---Format a GitHub repository handle into a URL.
---@param package_handle string 'username/repo'
---@return string
local function gh(package_handle) return "https://github.com/" .. package_handle end

---Checks whether a string is a full URL (http(s))
---@param src string
---@return boolean
local function is_url(src) return src:match "^https?://" ~= nil end

---Converts a GitHub shorthand into a full repository URL.
---If input is already a full URL, returns it unchanged.
---@param src string
---@return string
local function resolve_src(src)
  if is_url(src) then return src end

  return gh(src)
end

vim.pack.add { gh "echasnovski/mini.misc" }
local misc = require "mini.misc"

---Copy specified keys from source to tbl if they exist.
---@generic T: table
---@generic S: table
---@param tbl T
---@param source S
---@param keys string[]
local function copy_if(tbl, source, keys)
  for _, key in ipairs(keys) do
    local value = source[key]
    if value ~= nil then tbl[key] = value end
  end
end

---Join a string or list of strings into a single comma-separated string.
---@param v string|string[]
---@return string
local function join(v)
  if type(v) == "string" then return v end
  return table.concat(v, ",")
end

---Checks whether `kind` matches `ev_kind` (supports string or list forms)
---@param kind PackChangedKind
---@param ev_kind PackChangedKind|table<PackChangedKind>
---@return boolean
local function match_kind(kind, ev_kind)
  if type(kind) == "table" then
    for _, k in ipairs(kind) do
      if k == ev_kind then return true end
    end
    return false
  end

  return kind == ev_kind
end

---Ensure the input is a list of PackSpec.
---@param x? PackSpec|PackSpec[]
---@return PackSpec[]
local function normalize_pack_spec_list(x)
  if not x then return {} end

  if type(x) == "string" or x.src then return { x } end

  return x
end

---Ensure the input is a list of PluginSpec.
---@param spec PluginSpec|PluginSpec[]
---@return PluginSpec[]
local function normalize_plugin_spec_list(spec)
  if not spec then return {} end
  if spec.src then return { spec } end
  return spec
end

---Ensure the input is a list of PackHook.
---@param hooks PackHook|PackHook[]|nil
---@return PackHook[]
local function normalize_hooks(hooks)
  if not hooks then return {} end

  if hooks.kind then return { hooks } end

  return hooks
end

---Extract the plugin name from a PackSpec.
---@param spec PackSpec
---@return string
local function name_from_spec(spec)
  if spec.name then return spec.name end

  return spec.src:match("([^/]+)$"):gsub("%.nvim$", "")
end

---Schedule a function to run based on a trigger string.
---@param trigger string "'now' | 'later' | 'event:...' | 'filetype:...'"
---@param f function
local function on_trigger(trigger, f) misc.safely(trigger, f) end

---Convert a PluginSpec to a standard vim.pack.Spec.
---@param plugin_spec PluginSpec
---@return vim.pack.Spec
local function plugin_spec_to_pack_spec(plugin_spec)
  local pack_spec = {}
  copy_if(pack_spec, plugin_spec, { "src", "version", "name" })

  pack_spec.name = name_from_spec(pack_spec)

  return pack_spec
end

---Resolve the load trigger string from lazy, event, or filetype flags.
---@param lazy? boolean
---@param event? string|string[]
---@param filetype? string|string[]
---@return string "'now' | 'later' | 'event:Name\[,Name2\]' | 'filetype:ft1\[,ft2\]'"
local function handle_trigger(lazy, event, filetype)
  if lazy then return "later" end

  local function fmt(prefix, v) return v and (prefix .. join(v)) or nil end

  return fmt("event:", event) or fmt("filetype:", filetype) or "now"
end

---Register a PackChanged autocommand for a specific plugin and hook.
---@param plugin string
---@param hook PackHook
local function setup_autocmd(plugin, hook)
  vim.api.nvim_create_autocmd("PackChanged", {
    desc = "PackChanged hook for " .. plugin,
    group = pack_changed_group,
    callback = function(ev)
      local data = ev.data

      if data.spec.name ~= plugin then return end

      if not match_kind(data.kind, hook.kind) then return end

      if type(hook.action) == "string" then
        vim.cmd(hook.action)
      else
        hook.action(data)
      end
    end,
  })
end

---Process and register all hooks for a plugin.
---@param name string
---@param hooks PackHook|PackHook[]
local function handle_pack_changed(name, hooks)
  hooks = normalize_hooks(hooks)

  for _, hook in ipairs(hooks) do
    setup_autocmd(name, hook)
  end
end

---Process dependencies and return them as PackEntry objects.
---@param deps? PackSpec|PackSpec[]
---@return PackEntry[]
local function handle_deps(deps)
  deps = normalize_pack_spec_list(deps)
  local deps_entries = {}
  for _, spec in ipairs(deps) do
    spec = type(spec) == "string" and { src = spec } or spec
    spec.src = resolve_src(spec.src)
    spec.name = name_from_spec(spec)
    table.insert(deps_entries, {
      spec = spec,
      name = spec.name,
      download_only = true,
    })
  end

  return deps_entries
end

---Generate the configuration function for a plugin, including dependency loading.
---@param name string
---@param opts? table
---@param config? fun(opts?: table)
---@param deps PackEntry[]
---@return fun()
local function handle_config(name, opts, config, deps)
  return function()
    for _, dep in ipairs(deps or {}) do
      vim.cmd.packadd(dep.name)
    end

    if config then
      config(opts)
    else
      -- local ok, mod = pcall(require, name)
      local mod = require(name)
      if type(mod.setup) == "function" then mod.setup(opts) end
    end
  end
end

---Identity function for plugin specifications to provide type hints.
---@param spec PluginSpec
---@return PluginSpec
function M.plugin(spec) return spec end

---Process a plugin specification table and register it for loading.
---@param spec PluginSpec
local function handle_single_spec(spec)
  if vim.g.vscode and not (spec.vscode and spec.vscode) then return end

  spec.src = resolve_src(spec.src)

  local pack_spec = plugin_spec_to_pack_spec(spec)
  local trigger = handle_trigger(spec.lazy, spec.event, spec.filetype)

  handle_pack_changed(pack_spec.name, spec.pack_changed)

  local deps = handle_deps(spec.dependencies)
  for _, dep in ipairs(deps or {}) do
    table.insert(plugins, dep)
  end

  local config = handle_config(pack_spec.name, spec.opts, spec.config, deps)

  table.insert(plugins, {
    spec = pack_spec,
    trigger = trigger,
    config = config,
    name = pack_spec.name,
  })
end

---Process one or multiple plugin specification tables and register them for loading.
---Accepts either a single PluginSpec or a list of PluginSpec entries.
---@param specs PluginSpec|PluginSpec[]
function M.handle_spec_table(specs)
  specs = normalize_plugin_spec_list(specs)

  for _, spec in ipairs(specs) do
    handle_single_spec(spec)
  end
end

---Finalize plugin registration and schedule loading according to triggers.
function M.sync()
  vim.pack.add(
    vim.tbl_map(function(p) return p.spec end, plugins),
    { load = function() end }
  )

  for _, item in ipairs(plugins) do
    if item.download_only then goto continue end

    local do_load = function()
      vim.cmd.packadd(item.name)
      if item.config then item.config() end
    end

    on_trigger(item.trigger, do_load)

    ::continue::
  end
end

return M
