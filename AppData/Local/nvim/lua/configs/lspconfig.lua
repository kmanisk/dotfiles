-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require("lspconfig")

-- EXAMPLE
local servers = { "html", "cssls" }
local nvlsp = require("nvchad.configs.lspconfig")

-- lsps with default config
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	})
end

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
