return {
    'ribru17/bamboo.nvim',
	cond = function()
		return not vim.g.vscode -- Exclude this plugin in VSCode
	end,
    lazy = false,
    config = function()
        -- Setup the bamboo plugin
        require('bamboo').setup()
        -- Optionally load it if required
        -- require('bamboo').load()
    end,
}
