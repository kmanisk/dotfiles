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
		{ "wellle/targets.vim" },
		{
			"max397574/better-escape.nvim",
			config = function()
				-- Suppress notifications temporarily
				vim.notify = function() end

				require("better_escape").setup({
					mapping = { "jk" }, -- Keybinding for escaping insert mode
					timeout = 300, -- Timeout for key sequence in milliseconds
					clear_empty_lines = true, -- Clear empty lines when exiting insert mode
					silent = true, -- Suppress messages
					-- keys = function()
					-- Get the current buffer name
					-- local bufname = vim.api.nvim_buf_get_name(0)

					-- Use regex to match "vifm" followed by anything
					-- if bufname:match("^vifm:.*") then
					-- 	return "" -- No escape behavior in Vifm windows
					-- end

					-- return "<ESC>" -- Default escape behavior
					-- end,
				})

				-- Restore original notify function
				vim.notify = vim.old_notify or vim.notify
			end,
		},
		--
		-- {
		-- 	"smoka7/hop.nvim",
		-- 	version = "*",
		-- 	opts = {
		-- 		keys = "etovxqpdygfblzhckisuran",
		-- 	},
		-- 	config = function()
		-- 		local hop = require("hop")
		-- 		local directions = require("hop.hint").HintDirection
		-- 		vim.keymap.set("", "f", function()
		-- 			hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
		-- 		end, { remap = true })
		-- 		vim.keymap.set("", "F", function()
		-- 			hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
		-- 		end, { remap = true })
		-- 		vim.keymap.set("", "t", function()
		-- 			hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
		-- 		end, { remap = true })
		-- 		vim.keymap.set("", "T", function()
		-- 			hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
		-- 		end, { remap = true })
		-- 	end,
		-- },
	}, {
		-- Explicitly set paths for Lazy.nvim to use VSCode-specific directories
		root = vscode_data_path .. "/lazy",
		lockfile = vscode_state_path .. "/lazy-lock.json",
		state = vscode_state_path .. "/lazy/state.json",
		cache = vscode_cache_path,
	})
end
