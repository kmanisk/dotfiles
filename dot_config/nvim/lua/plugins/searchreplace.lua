return {
	"roobert/search-replace.nvim",
	cond = function()
		return not vim.g.vscode -- Exclude this plugin in VSCode
	end,
	lazy = false, -- Ensure lazy loading
	cmd = "SearchReplaceOpen", -- Trigger loading with the command
	config = function()
		require("search-replace").setup({
			-- Optionally override defaults
			default_replace_single_buffer_options = "gcI",
			default_replace_multi_buffer_options = "egcI",
		})
	end,
}
