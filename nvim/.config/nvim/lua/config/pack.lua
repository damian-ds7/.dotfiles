local base = vim.fn.stdpath "config" .. "/lua/plugins"

for _, path in ipairs(vim.fn.globpath(base, "**/*.lua", false, true)) do
  local rel = vim.fs.relpath(base, path)
  if rel and not rel:match "^_" and not rel:match "/_" then
    local pack_spec = require("plugins." .. rel:gsub("/", "."):gsub("%.lua$", ""))
    require("utils.pack").handle_spec_table(pack_spec)
  end
end

require("utils.pack").sync()
