local registry = require "core.lang_reg"

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-cpp", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client.name == "clangd" then
      vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", {
        buffer = event.buf,
        desc = "LSP: Switch Source/Header (C/C++)",
      })
    end
  end,
})

local lang = {
  servers = {
    clangd = {
      -- keys = {
      --   { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
      -- },
      root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja",
        ".git",
      },
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
    },
  },

  tools = { "codelldb", "clang-format" },

  treesitter = { "cpp", "cmake" },
}

registry.register(lang)

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.configurations = opts.configurations or {}

      opts.adapters["codelldb"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      local cpp_config = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = function() return vim.uv.fs_realpath(vim.fn.getcwd()) end,
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = function() return vim.uv.fs_realpath(vim.fn.getcwd()) end,
          stopOnEntry = false,
        },
      }

      opts.configurations.cpp = cpp_config
      opts.configurations.c = cpp_config
    end,
  },
  {
    "Civitasv/cmake-tools.nvim",
    -- ft = { "c", "cpp", "cmake" },
    cond = function() return vim.fn.filereadable(vim.uv.cwd() .. "/CMakeLists.txt") == 1 end,
    init = function()
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("LazyLoadCMake", { clear = true }),
        callback = function()
          if vim.fn.filereadable(vim.uv.cwd() .. "/CMakeLists.txt") == 1 then require("lazy").load { plugins = { "cmake-tools.nvim" } } end
        end,
      })
    end,
    opts = {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_build_directory = "build/${variant:buildType}",
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,
      cmake_generate_options = {
        "-G",
        "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
      },

      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.loop.cwd() .. "/build",
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
