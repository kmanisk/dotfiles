-- VSCode-specific profile for LazyVim
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Only load these plugins if in VSCode
if vim.g.vscode then
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

	-- Bootstrap LazyVim if not already installed
	if not vim.uv.fs_stat(lazypath) then
		local repo = "https://github.com/folke/lazy.nvim.git"
		vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
	end

	vim.opt.rtp:prepend(lazypath)

	local lazy_config = require("configs.lazy")

	-- Load plugins for VSCode environment
	require("lazy").setup({
		{
			"kylechui/nvim-surround",
			event = "VeryLazy",
			config = function()
				require("nvim-surround").setup({
					-- Custom configuration for VSCode if needed
				})
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
				map("n", "s", '<Cmd>lua require("leap").leap({ target_windows = { vim.fn.win_getid() } })<CR>', opts)
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
	})
end
