--- lua/plugins/conform.lua
return {
	"stevearc/conform.nvim",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "ConformInfo" },
	keys = {
		{
			-- Manual format trigger
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = { "n", "v" },
			desc = "Code Format",
		},
	},
	opts = {
		-- Define which formatters to use per filetype
		formatters_by_ft = {
			lua = { "stylua" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			zsh = { "shfmt" },

			-- Web / Config
			javascript = { "prettier" },
			typescript = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
		},

		-- Enable auto-format on save for all filetypes listed above
		format_on_save = true,
	},

	-- Auto-format when saving a file
	config = function(_, opts)
		require("conform").setup(opts)

		-- Create autocommand for BufWritePre to format automatically
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function()
				require("conform").format({ async = false, lsp_fallback = true })
			end,
		})
	end,
}
