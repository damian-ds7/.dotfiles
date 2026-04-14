vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local buf = event.buf

    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = buf, desc = "LSP: " .. desc })
    end

    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_group = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end
    local builtin = lazy.require_on_index "telescope.builtin"

    map("<leader>cR", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
    map("<leader>cl", vim.lsp.codelens.run, "Codelens", { "n", "x" })
    map("<leader>cc", vim.lsp.buf.declaration, "Goto Declaration")
    map("<leader>cD", function() builtin.lsp_definitions { reuse_win = true } end, "Definition")
    map("<leader>cr", function() builtin.lsp_references { reuse_win = true } end, "References")
    map("<leader>ci", function() builtin.lsp_implementations { reuse_win = true } end, "Implementation")
    map("<leader>ct", function() builtin.lsp_type_definitions { reuse_win = true } end, "Type Definition")
    map("<leader>cs", function() builtin.lsp_document_symbols() end, "Document Symbols")
    map("<leader>cS", function() builtin.lsp_dynamic_workspace_symbols() end, "Workspace Symbols")

    map("grD", vim.lsp.buf.declaration, "Goto Declaration")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("grr", function() builtin.lsp_references { reuse_win = true } end, "References")
    map("gd", function() builtin.lsp_definitions { reuse_win = true } end, "Definition")
    map("gri", function() builtin.lsp_implementations { reuse_win = true } end, "Implementation")
    map("grt", function() builtin.lsp_type_definitions { reuse_win = true } end, "Type Definition")
    map("gs", function() builtin.lsp_document_symbols() end, "Document Symbols")
    map("gS", function() builtin.lsp_dynamic_workspace_symbols() end, "Workspace Symbols")

    if client and client:supports_method("textDocument/inlayHint", buf) then
      vim.lsp.inlay_hint.enable(true)
      vim.keymap.set(
        "n",
        "<leader>uh",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }) end,
        { buffer = buf, desc = "Toggle Inlay Hints" }
      )

      local hint_state = false

      vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
        buffer = buf,
        callback = function(args)
          if args.event == "InsertEnter" then
            hint_state = vim.lsp.inlay_hint.is_enabled { bufnr = buf }
            if hint_state then vim.lsp.inlay_hint.enable(false, { bufnr = buf }) end
          else
            if hint_state then vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end
          end
        end,
      })
    end

    if client and client:supports_method "textDocument/codeLens" then
      vim.lsp.codelens.enable(true)
      vim.keymap.set(
        "n",
        "<leader>ue",
        function() vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled { bufnr = buf }) end,
        { buffer = buf, desc = "Toggle Codelens" }
      )
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local icons = require "utils.icons"
    vim.diagnostic.config {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
        },
      },
      float = { border = "rounded", source = "if_many" },
    }
  end,
})
