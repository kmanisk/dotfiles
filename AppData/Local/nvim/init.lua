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
    require("test")
    require("cusmap")
    require("plugins.themes.vscode")

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

-- Automatically source mappings.lua when saved
-- Automatically source mappings.lua on save
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	pattern = "lua/mappings.lua", -- Trigger only for mappings.lua
-- 	callback = function()
-- 		-- Source the current file
-- 		vim.cmd("source " .. vim.fn.expand("%:p"))
-- 		print("Reloaded mappings.lua")
-- 	end,
-- 	desc = "Automatically reload mappings.lua on save",
-- })
-- Automatically source all Lua files in the lua directory, excluding mappings.lua
-- -- Automatically source mappings.lua when saved
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	pattern = "lua/mappings.lua", -- Trigger only for mappings.lua in the lua directory
-- 	callback = function()
-- 		-- Construct the absolute path to mappings.lua
-- 		local mappings_path = vim.fn.stdpath("config") .. "\\lua\\mappings.lua"
-- 		if vim.fn.filereadable(mappings_path) == 1 then
-- 			vim.cmd("luafile " .. mappings_path) -- Source the file
-- 			print("Reloaded mappings.lua: " .. mappings_path)
-- 		else
-- 			print("Error: mappings.lua not found at " .. mappings_path)
-- 		end
-- 	end,
-- 	desc = "Automatically reload mappings.lua on save",
-- })
--
--
--worked
-- -- Auto-source specific Lua files on save
-- local auto_source_files = {
-- 	"test.lua",
-- 	"options.lua",
-- 	"cusmap.lua",
-- 	"mappings.lua",
-- }
--
-- for _, file in ipairs(auto_source_files) do
-- 	vim.api.nvim_create_autocmd("BufWritePost", {
-- 		pattern = "lua/" .. file,
-- 		callback = function()
-- 			local file_path = vim.fn.stdpath("config") .. "/lua/" .. file
-- 			if vim.fn.filereadable(file_path) == 1 then
-- 				vim.cmd("luafile " .. file_path)
-- 				print("Reloaded " .. file .. ": " .. file_path)
-- 			else
-- 				print("Error: " .. file .. " not found at " .. file_path)
-- 			end
-- 		end,
-- 		desc = "Automatically reload " .. file .. " on save",
-- 	})
-- end

