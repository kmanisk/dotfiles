local nvlsp = require "nvchad.configs.lspconfig"
local lspconfig = require "lspconfig"

nvlsp.defaults() -- Load NvChad's default LSP configurations

lspconfig.lua_ls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Specify LuaJIT for Neovim
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = {'vim'}, -- Recognize the `vim` global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
        checkThirdParty = false, -- Disable third-party library check
      },
      telemetry = {
        enable = false, -- Disable telemetry data
      },
    },
  },
}
--
--
--
-- -- load defaults i.e lua_lsp
-- require("nvchad.configs.lspconfig").defaults()
--
-- local lspconfig = require("lspconfig")
--
-- -- EXAMPLE
-- local servers = { "html", "cssls" }
-- local nvlsp = require("nvchad.configs.lspconfig")
--
-- -- lsps with default config
-- for _, lsp in ipairs(servers) do
-- 	lspconfig[lsp].setup({
-- 		on_attach = nvlsp.on_attach,
-- 		on_init = nvlsp.on_init,
-- 		capabilities = nvlsp.capabilities,
-- 	})
-- end
--
-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
-- ---- Configure JDK version and LSP for Java
-- require("lspconfig").jdtls.setup({
--     settings = {
--         java = {
--             configuration = {
--                 runtimes = {
--                     {
--                         name = "JavaSE-21",
--                         path = "/opt/jdk-21", -- Path to your JDK installation
--                         default = true,       -- Set this version as the default JDK
--                     },
--                 },
--             },
--         },
--     },
-- })
