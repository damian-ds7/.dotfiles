---@alias snacks.picker.prefix.Overrides {ignored?: boolean, ft?: string[]}

---@class snacks.Picker
---@field _prefix? snacks.picker.prefix.Overrides
---@field _base? {ft?: string|string[], glob?: string|string[]}

---@class snacks.picker.Config
---@field hidden? boolean
---@field ignored? boolean
---@field ft? string|string[]
---@field glob? string|string[]

local M = {}

--- Scans a chain of search-prefix directives at the start of `line`:
--- `!` includes gitignored files, `@ext[,ext2,...]` restricts the search to
--- those extensions. Chainable (`!@lua`). A leading `\!`/`\@` escapes the
--- directive (searches for a literal `!`/`@`).
---@param line string
---@return integer prefix_len bytes consumed from the start of `line`
---@return snacks.picker.prefix.Overrides overrides
---@return boolean escaped
function M.scan_prefix(line)
  if line:sub(1, 1) == "\\" then return 0, {}, true end
  local overrides = {}
  local i, n = 1, #line
  while i <= n do
    local c = line:sub(i, i)
    if c == "!" then
      overrides.ignored = true
      i = i + 1
    elseif c == "@" then
      local ext, after = line:match("^@([%w,]+)()", i)
      if not ext then break end
      overrides.ft = vim.split(ext, ",", { trimempty = true })
      i = after
    else
      break
    end
  end
  return i - 1, overrides, false
end

--- Returns the picker whose input buffer is `buf`, if any.
---@param buf integer
---@return snacks.Picker?
local function picker_for(buf)
  for _, picker in ipairs(Snacks.picker.get()) do
    if picker.input.win.buf == buf then return picker end
  end
end

---@param picker snacks.Picker
---@param overrides snacks.picker.prefix.Overrides
---@return boolean changed
local function set_opts(picker, overrides)
  local changed = not vim.deep_equal(overrides, picker._prefix or {})
  if not changed then return false end
  picker._prefix = overrides

  -- baseline from how the picker was originally invoked, so a directive
  -- that doesn't touch ft/glob doesn't wipe out a caller-configured one
  picker._base = picker._base
    or {
      ft = picker.init_opts and picker.init_opts.ft,
      glob = picker.init_opts and picker.init_opts.glob,
    }

  picker.opts.ignored = overrides.ignored or false
  local ext_glob = overrides.ft
      and vim.tbl_map(function(e) return "*." .. e end, overrides.ft)
    or nil

  if picker.opts.finder == "grep" then
    picker.opts.ft = nil
    picker.opts.glob = ext_glob or picker._base.glob
  else
    picker.opts.glob = nil
    picker.opts.ft = overrides.ft or picker._base.ft
  end
  return true
end

---@param buf integer
local function on_change(buf)
  local picker = picker_for(buf)
  if not picker then return end
  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  local prefix_len, overrides, escaped = M.scan_prefix(line)
  local rest = escaped and line:sub(2) or line:sub(prefix_len + 1):gsub("^%s+", "")

  local changed = set_opts(picker, overrides)

  if picker.opts.live then
    picker.input.filter.search = rest
  else
    picker.input.filter.pattern = rest
  end
  picker:find { refresh = changed }
end

--- Attaches the reactive prefix scanner to a picker input buffer. Safe to
--- call more than once per buffer.
---@param buf integer
function M.attach(buf)
  local timer = assert((vim.uv or vim.loop).new_timer())
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    buffer = buf,
    callback = function()
      -- must run after snacks' own input handler (throttled at 50ms/200ms
      -- for non-live/live pickers) or it would overwrite our corrected
      -- filter.pattern/search with the raw line (prefix chars included).
      local picker = picker_for(buf)
      local delay = (picker and picker.opts.live) and 220 or 50
      timer:stop()
      timer:start(
        delay,
        0,
        vim.schedule_wrap(function()
          if vim.api.nvim_buf_is_valid(buf) then on_change(buf) end
        end)
      )
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      if not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end,
  })
end

--- Registers the picker input filetype hook once. Call from plugin setup.
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_picker_input",
    callback = function(ev) M.attach(ev.buf) end,
  })
end

return M
