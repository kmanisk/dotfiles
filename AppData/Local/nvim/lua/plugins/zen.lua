-- Lua
return {
	"folke/zen-mode.nvim",
	opts = {
		vim.keymap.set("n", "<Leader>zz", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" }),

		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		window = {
			backdrop = 1,
			width = 130,
			height = 1,
			options = {
				-- Uncomment any options you'd like to use
				-- signcolumn = "no",
				-- number = false,
				-- relativenumber = false,
				-- cursorline = false,
				-- cursorcolumn = false,
				-- foldcolumn = "0",
				-- list = false,
			},
		},
		plugins = {
			options = {
				enabled = true,
				ruler = false,
				showcmd = false,
				laststatus = 0,
			},
			twilight = { enabled = true },
			gitsigns = { enabled = false },
			tmux = { enabled = false },
			todo = { enabled = false },
			kitty = {
				enabled = false,
				font = "+4",
			},
			alacritty = {
				enabled = false,
				font = "14",
			},
			wezterm = {
				enabled = false,
				font = "+4",
			},
			neovide = {
				enabled = false,
				scale = 1.2,
				disable_animations = {
					neovide_animation_length = 0,
					neovide_cursor_animate_command_line = false,
					neovide_scroll_animation_length = 0,
					neovide_position_animation_length = 0,
					neovide_cursor_animation_length = 0,
					neovide_cursor_vfx_mode = "",
				},
			},
		},
		on_open = function(win) end,
		on_close = function() end,
	},
}
