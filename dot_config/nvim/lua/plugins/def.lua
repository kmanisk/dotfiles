return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim", -- add this
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup()
			telescope.load_extension("live_grep_args") -- load the extension
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = "LazyGit", -- load only when :LazyGit is called
		config = function()
			vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>", { desc = "Open LazyGit" })
		end,
	},
	{
		"monaqa/dial.nvim",
		event = "VeryLazy",
		config = function()
			local dial = require("dial.map")

			vim.keymap.set("n", "<C-a>", "<Plug>(dial-increment)", { desc = "Dial Increment" })
			vim.keymap.set("n", "<C-x>", "<Plug>(dial-decrement)", { desc = "Dial Decrement" })
			vim.keymap.set("v", "<C-a>", "<Plug>(dial-increment)", { desc = "Dial Increment (visual)" })
			vim.keymap.set("v", "<C-x>", "<Plug>(dial-decrement)", { desc = "Dial Decrement (visual)" })

			vim.keymap.set("n", "g<C-a>", "<Plug>(dial-increment-additional)", { desc = "Dial Increment (add)" })
			vim.keymap.set("n", "g<C-x>", "<Plug>(dial-decrement-additional)", { desc = "Dial Decrement (add)" })

			vim.keymap.set("n", "+", "<Plug>(dial-increment)", { desc = "Dial Increment" })
			vim.keymap.set("n", "-", "<Plug>(dial-decrement)", { desc = "Dial Decrement" })
		end,
	},
	{
		"iquzart/toggleword.nvim",
		opts = {
			key = "<leader>tt",
		},
	},
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},
	{
		"windwp/nvim-spectre",
		cmd = "Spectre",
		keys = { { "<leader>S", "<cmd>Spectre<CR>", desc = "Search & Replace" } },
	},
	{
		"ethanholz/nvim-lastplace",
		event = "BufReadPost",
		opts = {},
	},
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		config = function()
			local neoscroll = require("neoscroll")
			neoscroll.setup({
				-- default easing for all scrolls
				easing = "quadratic",
				hide_cursor = false,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
			})

			-- define smooth scroll keymaps
			local keymaps = {
				["<C-u>"] = function()
					neoscroll.ctrl_u({ duration = 250 })
				end,
				["<C-d>"] = function()
					neoscroll.ctrl_d({ duration = 250 })
				end,
				["<C-b>"] = function()
					neoscroll.ctrl_b({ duration = 450 })
				end,
				["<C-f>"] = function()
					neoscroll.ctrl_f({ duration = 450 })
				end,
				["<C-y>"] = function()
					neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
				end,
				["<C-e>"] = function()
					neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
				end,
				["zt"] = function()
					neoscroll.zt({ half_win_duration = 250 })
				end,
				["zz"] = function()
					neoscroll.zz({ half_win_duration = 250 })
				end,
				["zb"] = function()
					neoscroll.zb({ half_win_duration = 250 })
				end,
			}

			local modes = { "n", "v", "x" }
			for key, func in pairs(keymaps) do
				vim.keymap.set(modes, key, func)
			end
		end,
	},
}
