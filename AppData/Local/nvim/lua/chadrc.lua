---@type ChadrcConfig
local M = {}
-- UI Configuration
M.ui = {
    theme = "gruvchad", -- Set the theme for Neovim
    transparency = true, -- Enable transparency
    -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    -- statusline configuration (if you want to use it)
    statusline = {
        theme = "vscode", -- default/vscode/vscode_colored/minimal
        separator_style = "round",
        order = nil,
        modules = nil,
    },

    cmp = {
        lspkind_text = true,
        style = "default", -- default/flat_light/flat_dark/atom/atom_colored
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
        bufwidth = 16,
    },
}

M.base46 = {
    theme = "gruvchad", -- Change to your preferred base46 theme (e.g., 'tokyonight', 'gruvbox', etc.)
    hl_add = {},
    hl_override = {},
    changed_themes = {},
    transparency = false,
    theme_toggle = { "gruvchad", "one_light" },
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
