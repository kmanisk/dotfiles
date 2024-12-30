return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		{
			"<leader>td",
			"<cmd>ToggleTerm size=40 dir=$HOME\\Desktop direction=horizontal<cr>",
			desc = "Open a horizontal terminal at the Desktop directory",
		},
	},
	config = function()
		require("toggleterm").setup()
	end,
}
