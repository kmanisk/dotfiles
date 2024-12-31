return {
	{
		"max397574/better-escape.nvim",
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
		lazy = true, -- Ensures the plugin loads only when needed
		config = function()
			require("better_escape").setup({
				timeout = 300, -- Custom timeout for waiting for key sequence (optional)
				mapping = { "jk", "jj" }, -- Key sequences to escape insert mode (optional)

				-- Example of customizing a mapping to call a function
				i = {
					[" "] = {
						["<tab>"] = function()
							-- Example of deferred execution to expand or jump with luasnip
							vim.defer_fn(function()
								-- Set undo point and expand or jump with luasnip
								vim.o.ul = vim.o.ul
								require("luasnip").expand_or_jump()
							end, 1)
						end,
					},
				},

				-- Disable the default mappings (optional)
				default_mappings = false, -- Disable the default 'jk'/'jj' mappings if you prefer custom ones
			})
		end,
	},
}
