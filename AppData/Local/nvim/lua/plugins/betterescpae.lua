return {
	"max397574/better-escape.nvim",
	config = function()
		-- Suppress notifications temporarily
		vim.notify = function() end
		require("better_escape").setup({
			mapping = { "jk" }, -- Keybinding for escaping insert mode
			timeout = 300, -- Timeout for key sequence in milliseconds
			clear_empty_lines = true, -- Clear empty lines when exiting insert mode
			silent = true, -- Suppress messages
		})

		-- Restore original notify function
		vim.notify = vim.old_notify or vim.notify
	end,
}
