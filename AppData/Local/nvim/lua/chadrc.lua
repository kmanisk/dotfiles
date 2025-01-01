local M = {}

-- UI Configuration
M.ui = {
	theme = "gruvbox", -- Set the theme for Neovim
	transparency = true, -- Enable transparency
	statusline = {
		theme = "vscode_colored", -- Choose a statusline theme (can be 'vscode', 'gruvbox', etc.)
		separator_style = "round", -- Choose a style for the separators in the statusline
	},
}
M.base46 = {
	theme = "gruvbox", -- Change to your preferred base46 theme (e.g., 'tokyonight', 'gruvbox', etc.)
}

-- M.create_fullsize_win = function(buf)
-- 	local tbline_height = #vim.o.tabline == 0 and -1 or 0
-- 	vim.api.nvim.open_win(buf, true, {
-- 		row = 1 + tbline_height,
-- 		col = 0,
-- 		width = vim.o.columns,
-- 		height = vim.o.lines - (3 + tbline_height),
-- 		relative = "editor",
-- 	})
-- end
-- Add custom mappings here
-- print("Loading chadrc.lua")
-- M.mappings = require("custom.maps")

return M
