local nvlsp = require "nvchad.configs.lspconfig"
local lspconfig = require "lspconfig"

nvlsp.defaults() -- Load NvChad's default LSP configurations
local servers = {}

-- lspconfig.lua_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
--   settings = {
--     Lua = {
--       runtime = {
--         version = 'LuaJIT', -- Specify LuaJIT for Neovim
--         path = vim.split(package.path, ';'),
--       },
--       diagnostics = {
--         globals = {'vim'}, -- Recognize the `vim` global
--       },
--       workspace = {
--         library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
--         checkThirdParty = false, -- Disable third-party library check
--       },
--       telemetry = {
--         enable = false, -- Disable telemetry data
--       },
--     },
--   },
-- }
--
-- lsps with default config
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	})
end
--
--
--python lspconfig example
-- lspconfig.pyright.setup({
--   on_attach = function(client, bufnr)
--     local bufopts = { noremap = true, silent = true, buffer = bufnr }
--     -- Key mappings for LSP functions
--     vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
--     vim.keymap.set("n", "L", vim.lsp.buf.hover, bufopts)
--     vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
--     vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
--     vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
--   end,
--   capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
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
