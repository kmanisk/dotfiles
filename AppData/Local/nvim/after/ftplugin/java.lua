

-- Ensure Mason installs jdtls
require('mason').setup()
--
-- require('mason-lspconfig').setup({
--   ensure_installed = { 'jdtls' },  -- Automatically install jdtls via Mason
-- })

-- Java configuration for Neovim

-- Setup nvim-java first
require('java').setup()

-- Now configure jdtls for Java language server
require('lspconfig').jdtls.setup({
  -- Any jdtls specific configurations can go here
  -- Do not define key mappings here to avoid overriding existing ones
})

-- Additional Java-specific configurations (optional)
-- You can add custom Java-specific settings below
