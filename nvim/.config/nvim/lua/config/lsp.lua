local icons = require "utils.icons"
local builtin = lazy.require_on_index "telescope.builtin"

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local lsp_attach_group = augroup("lsp-attach", { clear = true })
local lsp_highlight_group = augroup("lsp-highlight", { clear = false })
local lsp_diagnostics_group = augroup("lsp-diagnostics", { clear = false })

local function map(buf, keys, func, desc, mode)
  mode = mode or "n"
  vim.keymap.set(mode, keys, func, {
    buffer = buf,
    desc = "LSP: " .. desc,
  })
end

autocmd("LspAttach", {
  group = lsp_attach_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local buf = event.buf

    if not client then return end

    map(buf, "<leader>cr", vim.lsp.buf.rename, "Rename")
    map(buf, "<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
    map(buf, "<leader>cl", vim.lsp.codelens.run, "Codelens", { "n", "x" })
    map(buf, "<leader>cc", vim.lsp.buf.declaration, "Goto Declaration")

    map(
      buf,
      "<leader>cD",
      function() builtin.lsp_definitions { reuse_win = true } end,
      "Definition"
    )
    map(
      buf,
      "<leader>cR",
      function() builtin.lsp_references { reuse_win = true } end,
      "References"
    )
    map(
      buf,
      "<leader>ci",
      function() builtin.lsp_implementations { reuse_win = true } end,
      "Implementation"
    )
    map(
      buf,
      "<leader>ct",
      function() builtin.lsp_type_definitions { reuse_win = true } end,
      "Type Definition"
    )
    map(
      buf,
      "<leader>cs",
      function() builtin.lsp_document_symbols() end,
      "Document Symbols"
    )
    map(
      buf,
      "<leader>cS",
      function() builtin.lsp_dynamic_workspace_symbols() end,
      "Workspace Symbols"
    )

    map(buf, "grD", vim.lsp.buf.declaration, "Goto Declaration")
    map(buf, "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map(
      buf,
      "grr",
      function() builtin.lsp_references { reuse_win = true } end,
      "References"
    )
    map(
      buf,
      "gd",
      function() builtin.lsp_definitions { reuse_win = true } end,
      "Definition"
    )
    map(
      buf,
      "gri",
      function() builtin.lsp_implementations { reuse_win = true } end,
      "Implementation"
    )
    map(
      buf,
      "grt",
      function() builtin.lsp_type_definitions { reuse_win = true } end,
      "Type Definition"
    )
    map(buf, "gs", function() builtin.lsp_document_symbols() end, "Document Symbols")
    map(
      buf,
      "gS",
      function() builtin.lsp_dynamic_workspace_symbols() end,
      "Workspace Symbols"
    )

    if client.server_capabilities.documentHighlightProvider then
      autocmd({ "CursorHold", "CursorHoldI" }, {
        group = lsp_highlight_group,
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })

      autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = lsp_highlight_group,
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client:supports_method("textDocument/inlayHint", buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })

      map(
        buf,
        "<leader>uh",
        function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled { bufnr = buf },
            { bufnr = buf }
          )
        end,
        "Toggle Inlay Hints"
      )
    end

    if client:supports_method "textDocument/codeLens" then
      map(
        buf,
        "<leader>ue",
        function()
          vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled { bufnr = buf })
        end,
        "Toggle Codelens"
      )
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = lsp_diagnostics_group,
  once = true,
  callback = function()
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
      float = {
        border = "rounded",
        source = "if_many",
      },
    }
  end,
})
