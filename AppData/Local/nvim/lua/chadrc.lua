local M = {}

-- UI Configuration
M.ui = {
	theme = "ayu_dark", -- Set the theme for Neovim
	-- transparency = true, -- Enable transparency
	-- statusline = {
	-- 	theme = "vscode_colored", -- Statusline theme
	-- 	separator_style = "round", -- Separator style for the statusline
	-- },
	statusline = {
		theme = "vscode_colored", -- Choose a statusline theme (can be 'vscode', 'gruvbox', etc.)
		separator_style = "round", -- Choose a style for the separators in the statusline
	},
}

M.base46 = {
	theme = "ayu_dark", -- Change to your preferred base46 theme (e.g., 'tokyonight', 'gruvbox', etc.)
}
-- Add custom mappings here
-- print("Loading chadrc.lua")
-- M.mappings = require("custom.maps")

return M
