-- VSCode-specific profile for LazyVim
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

if vim.g.vscode then
	-- Define custom paths for VSCode-specific setup
	local vscode_data_path = vim.fn.stdpath("data"):gsub("nvim%-data", "nvim-data/vscode")
	local vscode_state_path = vim.fn.stdpath("state"):gsub("nvim%-data", "nvim-data/vscode")
	local vscode_cache_path = vim.fn.stdpath("cache"):gsub("nvim%-data", "nvim-data/vscode")

	-- Path to lazy.nvim in the VSCode-specific data folder
	local lazypath = vscode_data_path .. "/lazy/lazy.nvim"

	-- Bootstrap Lazy.nvim if not already installed
	if not vim.uv.fs_stat(lazypath) then
		local repo = "https://github.com/folke/lazy.nvim.git"
		vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
	end

	-- Prepend Lazy.nvim to runtime path
	vim.opt.rtp:prepend(lazypath)

	-- Configure Lazy.nvim plugins for VSCode environment
	require("lazy").setup({
		{
			"kylechui/nvim-surround",
			event = "VeryLazy",
			config = function()
				require("nvim-surround").setup({})
			end,
		},
		{ "nvim-lua/plenary.nvim" },
		{ "numToStr/Comment.nvim", config = true, event = "VeryLazy" },
		{ "ThePrimeagen/harpoon", config = true, event = "VeryLazy" },
		{ "tpope/vim-repeat" },
		{ "wellle/targets.vim", lazy = false },
		{
			"ggandor/leap.nvim",
			config = function()
				require("leap").add_default_mappings()
				vim.keymap.set(
					"n",
					"s",
					'<Cmd>lua require("leap").leap({ target_windows = { vim.fn.win_getid() } })<CR>',
					{ noremap = true, silent = true }
				)
			end,
		},
		{
			"vscode-neovim/vscode-multi-cursor.nvim",
			event = "VeryLazy",
			opts = {},
		},
		{
			"chentoast/marks.nvim",
			event = "VeryLazy",
			opts = {},
		},
	}, {
		-- Explicitly set paths for Lazy.nvim to use VSCode-specific directories
		root = vscode_data_path .. "/lazy",
		lockfile = vscode_state_path .. "/lazy-lock.json",
		state = vscode_state_path .. "/lazy/state.json",
		cache = vscode_cache_path,
	})
end
