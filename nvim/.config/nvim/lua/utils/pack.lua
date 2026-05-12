local M = {}
local plugins = {}

---@param package_handle string 'username/repo'
function M.gh(package_handle) return "https://github.com/" .. package_handle end

vim.pack.add { M.gh "echasnovski/mini.misc" }
local misc = require "mini.misc"

---@param f function
local function now(f) misc.safely("now", f) end

---@param f function
local function later(f) misc.safely("later", f) end

---@param trigger string 'event:...' | 'filetype:...'
---@param f function
local function on_trigger(trigger, f) misc.safely(trigger, f) end

local function name_from_spec(spec) return spec.name or spec.src:match "([^/]+)$" end

---@param ... string|vim.pack.Spec
function M.ensure(...)
  for _, spec in ipairs { ... } do
    spec = type(spec) == "string" and { src = spec } or spec
    table.insert(plugins, {
      spec = spec,
      name = name_from_spec(spec),
      ensure_only = true,
    })
  end
end

--- Collect a plugin for installation + deferred loading
---@param spec string|vim.pack.Spec
---@param config function|nil
---@param trigger string|nil  'now' | 'later' | 'event:Name[,Name2]'
function M.add(spec, config, trigger)
  spec = type(spec) == "string" and { src = spec } or spec

  if vim.g.vscode and not (spec.data and spec.data.vscode) then return end

  table.insert(plugins, {
    spec = spec,
    name = name_from_spec(spec),
    trigger = trigger or "now",
    config = config,
  })
end

--- Install all plugins and wire up triggers
function M.sync()
  vim.pack.add(
    vim.tbl_map(function(p) return p.spec end, plugins),
    { load = function() end }
  )

  for _, item in ipairs(plugins) do
    if item.ensure_only then goto continue end

    local do_load = function()
      vim.cmd.packadd(item.name)
      if item.config then item.config() end
    end

    if item.trigger == "now" then
      now(do_load)
    elseif item.trigger == "later" then
      later(do_load)
    else
      on_trigger(item.trigger, do_load)
    end

    ::continue::
  end
end

---@alias PackChangedKind string|string[]

---@param plugin string
---@param kind PackChangedKind
---@param fn fun(data)
function M.on_pack_changed(plugin, kind, fn)
  vim.api.nvim_create_autocmd("PackChanged", {
    desc = "Run callback on matching PackChanged events",
    group = vim.api.nvim_create_augroup("pack-events", { clear = false }),
    callback = function(ev)
      local data = ev.data
      local name = data.spec.name
      local ev_kind = data.kind

      if name ~= plugin then return end

      local match = false

      if type(kind) == "table" then
        for _, k in ipairs(kind) do
          if k == ev_kind then
            match = true
            break
          end
        end
      else
        match = kind == ev_kind
      end

      if not match then return end

      fn(data)
    end,
  })
end

return M
