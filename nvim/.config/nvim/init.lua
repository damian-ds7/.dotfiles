local socket_dir = os.getenv("NVIM_SOCKET_DIR")

if socket_dir then
  if vim.fn.isdirectory(socket_dir) == 0 then
    vim.fn.mkdir(socket_dir, "p")
  end

  local seconds = os.time()
  local nsec = vim.uv.hrtime() % 1000000000
  local socket_name = string.format("nvim-%d%09d.sock", seconds, nsec)
  local socket_path = socket_dir .. "/" .. socket_name

  local ok, err = pcall(vim.fn.serverstart, socket_path)

  if ok then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        vim.fn.delete(socket_path)
      end,
    })
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd("colorscheme " .. require("config.util").get_colorscheme())
