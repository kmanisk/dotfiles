-- Python-related configurations in after/ftplugin/python.lua
-- Only run these configurations if not in VSCode
if not vim.g.vscode then
  -- 1. Setup LSP for Python (using pyright)
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  local nvlsp = require("nvchad.configs.lspconfig")

  nvlsp.defaults() -- Loads nvchad's defaults

  -- Ensure pyright is installed
  require("mason").setup()
  mason_lspconfig.setup({
    ensure_installed = { "pyright" }, -- Ensure pyright is installed
  })

  -- Python LSP configuration example
  lspconfig.pyright.setup({
    on_attach = function(client, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      -- Key mappings for LSP functions
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "L", vim.lsp.buf.hover, bufopts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
      vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  })

  -- 2. Treesitter setup for Python
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "python" }, -- Ensure Python is installed for Treesitter
    highlight = {
      enable = true, -- Enable syntax highlighting
    },
  })

  -- 3. nvim-cmp for Python Autocompletion
  local cmp = require("cmp")
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item() -- Select the next item in the completion menu
          cmp.confirm({ select = true }) -- Automatically confirm the selection (like pressing Enter)
        else
          fallback() -- Default behavior (insert a tab character if no completion is visible)
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item() -- Move to the previous item in the completion menu
        else
          fallback() -- Default behavior (insert a tab character)
        end
      end, { "i", "s" }),
    }),
  })

  -- 4. Python-specific settings (Optional)
  -- You can add Python-specific options here, for example:
  -- vim.g.python3_host_prog = "/usr/bin/python3" -- Point to Python 3 binary (if necessary)
end
