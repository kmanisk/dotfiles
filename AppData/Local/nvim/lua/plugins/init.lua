return {
	{
		"NvChad/nvterm",
		enabled = false,
	},
	{
		"lewis6991/gitsigns.nvim",
		enabled = false,
	},
	{
		"stevearc/conform.nvim",
        enabled = false,
		-- event = "BufWritePre", -- uncomment for format on save
		-- opts = require("configs.conform"),
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	-- These are some examples, uncomment them if you want to see them work!
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"vimdoc",
				"html",
				"css",
			},
		},
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	{
		"CRAG666/code_runner.nvim",
		config = true,
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	{
		"Mofiqul/vscode.nvim",
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},


{
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    keys = "etovxqpdygfblzhckisuran", -- Define the keys for hop
    -- Initialize the hop module and directions
  cond = function()
    return not vim.g.vscode -- Exclude this plugin in VSCode
  end,
}
},
}
