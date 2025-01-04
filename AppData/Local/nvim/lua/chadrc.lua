local M = {}

-- UI Configuration
M.ui = {
	theme = "aquarium", -- Set the theme for Neovim
	transparency = true, -- Enable transparency
	statusline = {
		theme = "vscode_colored", -- Choose a statusline theme (can be 'vscode', 'gruvbox', etc.)
		separator_style = "round", -- Choose a style for the separators in the statusline
	},
	cmp = {
		lspkind_text = true,
		style = "atom_colored", -- default/flat_light/flat_dark/atom/atom_colored
		format_colors = {
			tailwind = false,
		},
	},
	telescope = { style = "bordered" }, -- borderless / bordered
	tabufline = {
		enabled = true,
		lazyload = true,
		order = { "treeOffset", "buffers", "tabs", "btns" },
		modules = nil,
	},
}

M.base46 = {
	theme = "aquarium", -- Change to your preferred base46 theme (e.g., 'tokyonight', 'gruvbox', etc.)
	hl_add = {},
	hl_override = {},
	integrations = {},
	changed_themes = {},
	transparency = false,
	theme_toggle = { "aquarium", "one_light" },
}

M.nvdash = {
	load_on_startup = false,
	header = {
		"                            ",
		"     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
		"   ▄▀███▄     ▄██ █████▀    ",
		"   ██▄▀███▄   ███           ",
		"   ███  ▀███▄ ███           ",
		"   ███    ▀██ ███           ",
		"   ███      ▀ ███           ",
		"   ▀██ █████▄▀█▀▄██████▄    ",
		"     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
		"                            ",
		"     Powered By  eovim    ",
		"                            ",
	},
	buttons = {
		{ txt = "  Find File", keys = "Spc f f", cmd = "Telescope find_files" },
		{ txt = "  Recent Files", keys = "Spc f o", cmd = "Telescope oldfiles" },
	},
}
--
-- M.term = {
-- 	winopts = { number = false },
-- 	sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
-- 	float = {
-- 		relative = "editor",
-- 		row = 0.3,
-- 		col = 0.25,
-- 		width = 0.5,
-- 		height = 0.4,
-- 		border = "single",
-- 	},
-- }

M.lsp = {
	signature = true,
}

M.cheatsheet = {
	theme = "grid", -- simple/grid
	excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" },
}

M.mason = {
	pkgs = {},
	skip = {},
}

M.colorify = {
	enabled = true,
	mode = "bg", -- fg, bg, virtual
	virt_text = "󱓻 ",
	highlight = { hex = true, lspvars = true },
}

return M
