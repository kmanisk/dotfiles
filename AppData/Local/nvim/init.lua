vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Set local leader key (Add this line here)

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require("configs.lazy")

-- load plugins
require("lazy").setup({
	{
		"NvChad/NvChad",
		lazy = false,
		branch = "v2.5",
		import = "nvchad.plugins",
	},

	{ import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
-- disable netrw at the very start of your init.lua

-- Check if running in VSCode
if vim.g.vscode then
	-- VSCode Neovim setup
	require("user.vscode_keymaps")
else
	-- Ordinary Neovim setup
	require("options")
	require("nvchad.autocmds")
	require("test")
	require("cusmap")
	require("plugins.themes.vscode")
	-- require("plugconfig.plugcode")
	-- require("plugins.session")
	-- require("plugconfig.session")
	--require("plugconfig.noiconf")
	-- require("custom.reload")
	vim.schedule(function()
		require("mappings")
	end)
end

-- Automatically source mappings.lua when saved
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "lua/mappings.lua", -- Trigger only for mappings.lua in the lua directory
	callback = function()
		-- Construct the absolute path to mappings.lua
		local mappings_path = vim.fn.stdpath("config") .. "\\lua\\mappings.lua"
		if vim.fn.filereadable(mappings_path) == 1 then
			vim.cmd("luafile " .. mappings_path) -- Source the file
			print("Reloaded mappings.lua: " .. mappings_path)
		else
			print("Error: mappings.lua not found at " .. mappings_path)
		end
	end,
	desc = "Automatically reload mappings.lua on save",
})
