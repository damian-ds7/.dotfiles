return {
  "nvim-neotest/neotest",
  optional = true,
  dependencies = {
    "fredrikaverpil/neotest-golang",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    opts.adapters["neotest-golang"] = require("neotest-golang")({
      go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
      dap_go_enabled = true,
    })
    return opts
  end,
}
