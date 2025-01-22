-- Set cache and leader keys
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Set local leader key

-- VSCode-specific setup
if vim.g.vscode then
	local vscode_plugins = require("user.vsplug")
	require("lazy").setup(vscode_plugins)
	require("user.vscode_keymaps")
else
	-- Bootstrap lazy and all plugins
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.uv.fs_stat(lazypath) then
		local repo = "https://github.com/folke/lazy.nvim.git"
		vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
	end

	vim.opt.rtp:prepend(lazypath)

	local lazy_config = require("configs.lazy")
	require("lazy").setup({
		{
			"NvChad/NvChad",
			lazy = false,
			branch = "v2.5",
			import = "nvchad.plugins",
		},

		{ import = "plugins" },

		{
			"nvim-lua/plenary.nvim",
			lazy = false,
		},
		{
			"L3MON4D3/LuaSnip",
			lazy = false,
		},
	})

	-- Load theme
	dofile(vim.g.base46_cache .. "defaults")
	dofile(vim.g.base46_cache .. "statusline")
	-- Ordinary Neovim setup
	require("options")
	--require("test")
	require("cusmap")
	-- require("plugins.themes.vscode")
	-- require("plugins.themes.bambo")

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

	-- Automatically source mappings.lua when saved
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "lua/mappings.lua", -- Trigger only for mappings.lua
		callback = function()
			local mappings_path = vim.fn.stdpath("config") .. "/lua/mappings.lua"
			if vim.fn.filereadable(mappings_path) == 1 then
				vim.cmd("source " .. mappings_path)
				-- print("Reloaded mappings.lua")
			else
				-- print("Error: mappings.lua not found")
			end
		end,
		desc = "Automatically source mappings.lua on save",
	})
end
