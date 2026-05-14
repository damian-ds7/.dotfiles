local cpp_dap_config = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = function() return vim.uv.fs_realpath(vim.fn.getcwd()) end,
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = function() return require("dap.utils").pick_process() end,
    cwd = function() return vim.uv.fs_realpath(vim.fn.getcwd()) end,
    stopOnEntry = false,
  },
}

local cpp_group = vim.api.nvim_create_augroup("lsp-cpp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = cpp_group,
  desc = "C/C++ specific LSP bindings",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "clangd" then return end

    vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", {
      buffer = event.buf,
      desc = "LSP: Switch Source/Header (C/C++)",
    })
  end,
})

return {
  lang {
    servers = {
      clangd = {
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--compile-commands-dir=build",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac",
          "Makefile",
          "meson.build",
          ".git",
        },
      },
    },
    tools = { "codelldb", "clang-format" },
    treesitter = { "cpp", "cmake" },
    formatters = {
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    dap = {
      adapters = {
        ["codelldb"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = { "--port", "${port}" },
          },
        },
      },
      configurations = {
        c = cpp_dap_config,
        cpp = cpp_dap_config,
      },
    },
  },
  plugin {
    src = "Civitasv/cmake-tools.nvim",
    filetype = { "cpp", "c", "cmake" },
    opts = {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_build_directory = "build/${variant:buildType}",
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,
      cmake_generate_options = { "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.uv.cwd() .. "/build",
      },
      cmake_executor = {
        name = "quickfix",
        opts = {
          show = "only_on_error",
          position = "belowright",
          size = 10,
          auto_close_when_success = true,
        },
      },
      cmake_runner = {
        name = "terminal",
        opts = {
          name = "CMake Run",
          split_direction = "horizontal",
          split_size = 11,
          focus = true,
        },
      },
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
      },
    },
  },
}
