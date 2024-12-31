-- Set cache and leader keys
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Set local leader key

-- Bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require("configs.lazy")

-- Load plugins only if not in VSCode
if not vim.g.vscode then
	require("lazy").setup({
		{
			"NvChad/NvChad",
			lazy = false,
			branch = "v2.5",
			import = "nvchad.plugins",
		},

		{ import = "plugins" },

		-- Additional Neovim plugins
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = { "lua", "python", "javascript", "html", "css" },
					highlight = { enable = true },
				})
			end,
		},
		{
			"nvim-lua/plenary.nvim",
			lazy = false,
		},
		{
			"hrsh7th/nvim-cmp",
			config = function()
				require("cmp").setup({
					-- Configuration for nvim-cmp
				})
			end,
		},
		{
			"L3MON4D3/LuaSnip",
			lazy = false,
		},
		-- Other plugins for Neovim
	})
end

-- Load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- VSCode-specific setup
if vim.g.vscode then
	-- VSCode keymaps and setup
	require("user.vscode_keymaps")
else
	-- Ordinary Neovim setup
	require("options")
	require("test")
	require("cusmap")
	require("plugins.themes.vscode")

	-- Load mappings after everything else
	vim.schedule(function()
		require("mappings")
	end)

	-- Automatically require all Lua files in pluginconfig directory
	local plugin_config_dir = vim.fn.stdpath("config") .. "/lua/plugconfig"
	for _, file in ipairs(vim.fn.readdir(plugin_config_dir)) do
		if file:match(".+%.lua$") then
			require("plugconfig." .. file:match("^(.*)%.lua$"))
		end
	end

	-- Autocmds and further Lua files sourcing
	require("nvchad.autocmds")

	local lua_dir = vim.fn.stdpath("config") .. "/lua"
	-- Loop through all files in the lua directory, excluding mappings.lua
	for _, file in ipairs(vim.fn.readdir(lua_dir)) do
		if file:match(".+%.lua$") and file ~= "mappings.lua" then
			-- Construct the full path to the Lua file
			local file_path = lua_dir .. "/" .. file
			-- Source the Lua file
			vim.cmd("source " .. file_path)
		end
	end

	-- Automatically source mappings.lua when saved
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "lua/mappings.lua", -- Trigger only for mappings.lua
		callback = function()
			local mappings_path = vim.fn.stdpath("config") .. "/lua/mappings.lua"
			if vim.fn.filereadable(mappings_path) == 1 then
				vim.cmd("source " .. mappings_path)
				print("Reloaded mappings.lua")
			else
				print("Error: mappings.lua not found")
			end
		end,
		desc = "Automatically source mappings.lua on save",
	})
end
