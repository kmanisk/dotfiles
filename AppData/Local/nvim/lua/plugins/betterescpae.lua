return {
	"nvim-zh/better-escape.vim", -- Correct inclusion without `require`
	config = function()
		-- Configure the plugin using Vim global variables (vim.g)
		vim.g.better_escape_interval = 200 -- Set time interval to 200 ms
		vim.g.better_escape_shortcut = { "jk", "kj" } -- Support multiple shortcuts
	end,
}
