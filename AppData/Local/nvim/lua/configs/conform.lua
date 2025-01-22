local options = {
	formatters_by_ft = {
		-- lua = { "stylua" },
		css = { "prettier" },
		html = { "prettier" },
     typescript = { "prettier" }, -- Add TypeScript
        javascript = { "prettier" }, -- Optional: Add JavaScript as well
        typescriptreact = { "prettier" }, -- Optional: Add React TSX files
        javascriptreact = { "prettier" }, -- Optional: Add React JSX files
	},

	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

return options
