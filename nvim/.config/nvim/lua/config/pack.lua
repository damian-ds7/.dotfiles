local utils = require "utils.pack"

local base = vim.fn.stdpath "config" .. "/lua/plugins"

for _, path in ipairs(vim.fn.globpath(base, "**/*.lua", false, true)) do
  local rel = vim.fs.relpath(base, path)
  if rel and not rel:match "^_" and not rel:match "/_" then
    require("plugins." .. rel:gsub("/", "."):gsub("%.lua$", ""))
  end
end

utils.sync()
