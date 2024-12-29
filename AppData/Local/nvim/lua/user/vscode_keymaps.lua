--[[
=============================================================================
                    VSCode Neovim Configuration
=============================================================================
--]]

-- Basic Setup
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- System Integration
vim.g.clipboard = vim.g.vscode_clipboard
-- Smarter Search
-- Ignore case during search unless uppercase is used
vim.o.ignorecase = true -- Case insensitive search
vim.o.smartcase = true -- Override ignorecase if search pattern contains uppercase

-- Highlight search matches
vim.o.hlsearch = true

-- Incremental search (shows matches as you type)
vim.o.incsearch = true

--[[
=============================================================================
                    Leader Key Configuration
=============================================================================
--]]
keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--[[
=============================================================================
                    Clipboard Operations
=============================================================================
--]]
vim.api.nvim_set_keymap("v", "y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "yy", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "p", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "p", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gp", 'o<Esc>"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gP", 'O<Esc>"+P', { noremap = true, silent = true })
keymap("v", "p", '"_dP', opts)

--[[
=============================================================================
                    Text Manipulation
=============================================================================
--]]
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

--[[
=============================================================================
                    Window Management
=============================================================================
--]]
-- vim.api.nvim_set_keymap('n', '<S-Left>', ':vertical resize -5<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-Right>', ':vertical resize +5<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-Down>', ':resize +5<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-Up>', ':resize -5<CR>', { noremap = true, silent = true })
keymap("n", "<leader>gv", function()
	require("vscode").action("workbench.action.splitEditor")
end, opts)
keymap("n", "<leader>gh", function()
	require("vscode").action("workbench.action.splitEditorDown")
end, opts)
keymap({ "n", "v" }, "<leader>oe", "<cmd>lua require('vscode').action('revealFileInOS')<CR>", opts)

--[[
=============================================================================
                    Navigation and Search
=============================================================================
--]]
--
keymap({ "n", "v" }, "<A-j>", "<cmd>lua require('vscode').action('workbench.action.nextEditorInGroup')<CR>")
keymap({ "n", "v" }, "<A-k>", "<cmd>lua require('vscode').action('workbench.action.previousEditorInGroup')<CR>")
keymap("n", "<leader>sf", ':lua require("vscode").action("periscope.search")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>rf",
	':lua require("vscode").action("filebunny.renameActiveFile")<CR>',
	{ noremap = true, silent = true }
)

vim.keymap.set("n", "<S-j>", function()
	require("vscode").call("workbench.action.nextEditorInGroup")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<S-k>", function()
	require("vscode").call("workbench.action.previousEditorInGroup")
end, { noremap = true, silent = true })

keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)
vim.o.hlsearch = true

--[[
=============================================================================
                    VSCode Integration Commands
=============================================================================
--]]
-- Quick Actions
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
keymap({ "n" }, "<leader>zz", "<cmd>lua require('vscode').action('workbench.action.toggleZenMode')<CR>")
keymap({ "n" }, "<leader>ct", "<cmd>lua require('vscode').action('workbench.action.closeOtherEditors')<CR>")
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({ "n", "v" }, "<leader>vp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
keymap({ "n", "v" }, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
vim.api.nvim_set_keymap(
	"n",
	"<leader>nf",
	':lua require("vscode").action("filebunny.createFile")<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>nF",
	':lua require("vscode").action("filebunny.createFolder")<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>lp",
	':lua require("vscode").action("livePreview.start.preview.atFile")<CR>',
	{ noremap = true, silent = true }
)

-- File Operations
keymap({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
keymap({ "n", "v" }, "<leader>w", "<cmd>lua require('vscode').action('workbench.action.files.save')<CR>")
keymap({ "n", "v" }, "<leader>of", "<cmd>lua require('vscode').action('workbench.action.files.openFile')<CR>", opts)

-- Editor Management
keymap({ "n", "v" }, "<leader>th", "<cmd>lua require('vscode').action('workbench.action.selectTheme')<CR>")
keymap({ "n", "v" }, "<leader>x", "<cmd>lua require('vscode').action('workbench.view.extensions')<CR>")
keymap({ "n", "v" }, "<leader>sk", "<cmd>lua require('vscode').action('workbench.action.openGlobalKeybindings')<CR>")
keymap({ "n", "v" }, "<leader>q", "<cmd>lua require('vscode').action('workbench.action.closeActiveEditor')<CR>")

-- Split Navigation
keymap({ "n", "v" }, "<C-h>", "<cmd>lua require('vscode').action('workbench.action.focusEditorLeft')<CR>")
keymap({ "n", "v" }, "<C-j>", "<cmd>lua require('vscode').action('workbench.action.focusEditorDown')<CR>")
keymap({ "n", "v" }, "<C-k>", "<cmd>lua require('vscode').action('workbench.action.focusEditorUp')<CR>")
keymap({ "n", "v" }, "<C-l>", "<cmd>lua require('vscode').action('workbench.action.focusEditorRight')<CR>")
keymap({ "n", "v" }, "<leader>rw", "<cmd>lua require('vscode').action('workbench.action.reloadWindow')<CR>")
keymap({ "n", "v" }, "<leader>s", "<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>")
-- make the sidebar close and focus on the file explorer and if pressed space e then closes the file explorer
keymap(
	"n",
	"<leader>e",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR><cmd>lua require('vscode').action('workbench.files.action.focusFilesExplorer')<CR>"
)
-- make close any side bar
vim.keymap.set(
	"n",
	"<leader>gq",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>",
	{ desc = "Toggle Sidebar" }
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>ow",
	'<Cmd>lua require("vscode").action("workbench.action.output.toggleOutput")<CR>',
	{ noremap = true, silent = true }
)

--[[
=============================================================================
                    Code Navigation and Actions
=============================================================================
--]]
keymap("n", "<leader>ca", "<cmd>lua require('vscode').action('editor.action.codeAction')<CR>")
keymap("n", "<leader>cr", "<cmd>lua require('vscode').action('editor.action.rename')<CR>")
keymap("n", "<leader>cs", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>")
keymap({ "n", "v" }, "<S-l>", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
keymap("n", "[d", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>", opts)
keymap("n", "]d", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>", opts)
vim.api.nvim_set_keymap(
	"n",
	"<leader>oc",
	":e $HOME/AppData/Local/nvim/lua/user/vscode_keymaps.lua<CR>",
	{ noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>vp", function()
	vim.fn.VSCodeNotify("workbench.actions.view.problems")
end)
vim.keymap.set("n", "<leader>gr", function()
	require("vscode").action("editor.action.referenceSearch.trigger")
end, { desc = "Show references" })

vim.keymap.set("n", "gd", function()
	require("vscode").action("editor.action.revealDefinition")
end, { desc = "Go to definition" })

vim.keymap.set("n", "gD", function()
	require("vscode").action("editor.action.peekDefinition")
end, { desc = "Peek definition" })

vim.keymap.set("n", "gr", function()
	require("vscode").action("editor.action.referenceSearch.trigger")
end, { desc = "Search references" })
keymap({ "n", "v" }, "<S-l>", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
vim.keymap.set("n", "<leader>gi", function()
	require("vscode").action("editor.action.goToImplementation")
end, { desc = "Go to implementation" })

vim.keymap.set("n", "za", function()
	require("vscode").action("editor.toggleFold")
end, { desc = "Toggle fold" })

--[[
=============================================================================
                    Custom Text Operations
=============================================================================
--]]
vim.api.nvim_set_keymap(
	"n",
	"gft",
	[[:execute "normal! f".nr2char(getchar())."a"<CR>]],
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>sa", "ggVG", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ya", 'ggVGd"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>da", "ggVGd", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>d;", ":s/;$//<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>d,", ":s/,$//<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;", "mzA;<Esc>`z", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>,", "mzA,<Esc>`z", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pr", [[mzOprintln!("{}", );<Esc>hi]], { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pr", [[mzOprintln!("{}", );<Esc>hi]], { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>bs",
	[[:%s/\([^\\]\)\\\([^\\]\)/\1\\\\\2/g<CR>]],
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "x", '"qx', { noremap = true, silent = true }) -- Fixed closing parenthesis
vim.api.nvim_set_keymap("n", "<leader>j", "J", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>k", "kJ", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>n", "o<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>N", "O<Esc>", { noremap = true, silent = true })

--[[
=============================================================================
                    Harpoon Integration
=============================================================================
--]]
keymap({ "n", "v" }, "<leader>ha", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
keymap({ "n", "v" }, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
keymap({ "n", "v" }, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")

for i = 1, 9 do
	keymap(
		{ "n", "v" },
		string.format("<leader>h%d", i),
		string.format("<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor%d')<CR>", i)
	)
end

--[[
=============================================================================
                    Project Management
=============================================================================
--]]
keymap({ "n", "v" }, "<leader>pa", "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>")
keymap({ "n", "v" }, "<leader>po", "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>")
keymap({ "n", "v" }, "<leader>pe", "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>")

--[[
=============================================================================
                    Plugin Configuration
=============================================================================
--]]
if vim.g.vscode then
	require("lazy").setup({
		{
			"kylechui/nvim-surround",
			event = "VeryLazy",
			config = function()
				require("nvim-surround").setup({
					-- Custom configuration for VS Code if needed
				})
			end,
		},
		{ "nvim-lua/plenary.nvim" },
		{ "numToStr/Comment.nvim", config = true, event = "VeryLazy" },
		{ "ThePrimeagen/harpoon", config = true, event = "VeryLazy" },
		{ "tpope/vim-repeat" },
		{ "wellle/targets.vim", lazy = false },
		{
			"ggandor/leap.nvim",
			config = function()
				require("leap").add_default_mappings()
				vim.api.nvim_set_keymap(
					"n",
					"s",
					'<Cmd>lua require("leap").leap({ target_windows = { vim.fn.win_getid() } })<CR>',
					{ noremap = true, silent = true }
				)
			end,
		},
		{
			"vscode-neovim/vscode-multi-cursor.nvim",
			event = "VeryLazy",
			cond = not not vim.g.vscode,
			opts = {},
		},
		{
			"chentoast/marks.nvim",
			event = "VeryLazy",
			opts = {},
		},
	})
end
