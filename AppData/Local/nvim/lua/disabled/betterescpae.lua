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
			keys = function()
				-- Get the current buffer name
				local bufname = vim.api.nvim_buf_get_name(0)

				-- Use regex to match "vifm" followed by anything
				if bufname:match("^vifm:.*") then
					return "" -- No escape behavior in Vifm windows
				end

				return "<ESC>" -- Default escape behavior
			end,
		})

		-- Restore original notify function
		vim.notify = vim.old_notify or vim.notify
	end,
}
