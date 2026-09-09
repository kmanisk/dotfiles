return {
	"smolck/command-completion.nvim",
	cond = function()
		return not vim.g.vscode -- Exclude this plugin in VSCode
	end,
}
