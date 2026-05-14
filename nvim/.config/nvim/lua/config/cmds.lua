vim.api.nvim_create_user_command(
  "PackInfo",
  function() vim.cmd "checkhealth vim.pack" end,
  {}
)

vim.api.nvim_create_user_command(
  "PackSync",
  function() vim.pack.update(nil, { target = "lockfile" }) end,
  {}
)

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local names, pack_opts = {}, { force = opts.bang }
  for _, arg in ipairs(opts.fargs) do
    if arg == "--offline" then
      pack_opts.offline = true
    elseif arg:match "^--target=" then
      pack_opts.target = arg:match "^--target=(.*)"
    else
      table.insert(names, arg)
    end
  end
  vim.pack.update(#names > 0 and names or nil, pack_opts)
end, {
  bang = true,
  nargs = "*",
  complete = function(arglead)
    return vim.tbl_filter(
      function(f) return f:find(arglead, 1, true) == 1 end,
      { "--offline", "--target=version", "--target=lockfile" }
    )
  end,
})

vim.api.nvim_create_user_command("PackDel", function(opts)
  local names = vim.split(opts.args, " ", { trimws = true })
  vim.pack.del(names, { force = opts.bang })
end, {
  bang = true,
  nargs = "+",
})

vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
  desc = "Show LSP Info",
})

vim.api.nvim_create_user_command("LspLog", function(_)
  local state_path = vim.fn.stdpath "state"
  local log_path = vim.fs.joinpath(state_path, "lsp.log")

  vim.cmd(string.format("edit %s", log_path))
end, {
  desc = "Show LSP log",
})

vim.api.nvim_create_user_command("LspRestart", "lsp restart", {
  desc = "Restart LSP",
})
