require("which-key").setup({
	layout = {
		height = { min = 2, max = 10 }, -- Adjust this for smaller height (min height and max height)
		width = { min = 20, max = 50 }, -- Adjust this as needed
		spacing = 3, -- Spacing between columns
		align = "center", -- Align columns to left, center, or right
	},
	cond = function()
		return not vim.g.vscode -- Exclude this plugin in VSCode
	end,
})
