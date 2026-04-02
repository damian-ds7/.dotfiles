vim.api.nvim_create_user_command("PackInfo", function() vim.cmd "checkhealth vim.pack" end, {})

vim.api.nvim_create_user_command("PackUpdate", function() vim.pack.update() end, {})

vim.api.nvim_create_user_command("PackDel", function(opts)
  local names = vim.split(opts.args, ",", { trimws = true })
  vim.pack.del(names)
end, { nargs = "+" })
