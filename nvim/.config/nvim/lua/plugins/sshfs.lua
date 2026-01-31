return {
  "uhs-robert/sshfs.nvim",
  enabled = false,
  opts = {
    connections = {
      sshfs_options = {
        reconnect = true,
        ConnectTimeout = 5,
        ServerAliveInterval = 15,
        ServerAliveCountMax = 3,
        dir_cache = "yes",
        dcache_timeout = 300,
        dcache_max_size = 10000,
      },
      control_persist = "10m",
      socket_dir = vim.fn.expand("$HOME/.ssh/sockets"),
    },
    mounts = {
      base_dir = vim.fn.expand("$HOME") .. "/ssh-mnt",
    },
  },
}
