--[[
=============================================================================
                    VSCode Neovim Configuration
=============================================================================
--]]

-- Basic Setup
-- print("vscode keymap loaded from neovim hello from lua")
local map = vim.keymap.set
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
map("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--[[
=============================================================================
                    Clipboard Operations
=============================================================================
--]]
map("v", "y", '"+y', opts)
map("n", "yy", '"+yy', opts)
map("n", "p", '"+p', opts)
map("v", "<leader>y", '"+y', opts)
map("v", "p", '"+p', opts)
map("n", "gp", 'o<Esc>"+p', opts)
map("n", "gP", 'O<Esc>"+P', opts)
map("v", "p", '"_dP', opts)

--[[
=============================================================================
                    Text Manipulation
=============================================================================
--]]
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("v", "J", ":m .+1<CR>==", opts)
map("v", "K", ":m .-2<CR>==", opts)
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("n", "+", "<C-a>", { noremap = true, silent = true })
map("n", "-", "<C-x>", { noremap = true, silent = true })
map("x", "K", ":move '<-2<CR>gv-gv", opts)

map(
	"n",
	"<leader>/",
	":call VSCodeNotify('editor.action.commentLine')<CR>",
	opts
)

map(
	"v",
	"<leader>/",
	":call VSCodeNotify('editor.action.commentLine')<CR>gv",
	opts
)

--[[
=============================================================================
                    Window Management
=============================================================================
--]]
-- map('n', '<S-Left>', ':vertical resize -5<CR>', opts)
-- map('n', '<S-Right>', ':vertical resize +5<CR>', opts)
-- map('n', '<S-Down>', ':resize +5<CR>', opts)
-- map('n', '<S-Up>', ':resize -5<CR>', opts)
map("n", "<leader>gv", function()
	require("vscode").action("workbench.action.splitEditor")
end, opts)
map("n", "<leader>gh", function()
	require("vscode").action("workbench.action.splitEditorDown")
end, opts)
map({ "n", "v" }, "<leader>oe", "<cmd>lua require('vscode').action('revealFileInOS')<CR>", opts)

--[[
=============================================================================
                    Navigation and Search
=============================================================================
--]]
--
map({ "n", "v" }, "<A-j>", "<cmd>lua require('vscode').action('workbench.action.nextEditorInGroup')<CR>")
map({ "n", "v" }, "<A-k>", "<cmd>lua require('vscode').action('workbench.action.previousEditorInGroup')<CR>")
map("n", "<leader>sf", ':lua require("vscode").action("periscope.search")<CR>', opts)
-- map(
-- 	"n",
-- 	"<leader>rf",
-- 	':lua require("vscode").action("filebunny.renameActiveFile")<CR>',
-- 	opts
-- )
--
map(
	"n",
	"<leader>rf",
	":call VSCodeNotify('filebunny.renameActiveFile')<CR>",
	opts
)

map(
	"n",
	"<leader>ff",
	":call VSCodeNotify('filebunny.openFile')<CR>",
	opts
)

map("n", "<S-j>", function()
	require("vscode").call("workbench.action.nextEditorInGroup")
end, opts)

map("n", "<S-k>", function()
	require("vscode").call("workbench.action.previousEditorInGroup")
end, opts)

map("n", "<Esc>", "<Esc>:noh<CR>", opts)
vim.o.hlsearch = true

--[[
=============================================================================
                    VSCode Integration Commands
=============================================================================
--]]
-- Quick Actions
map({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
map({ "n" }, "<leader>zz", "<cmd>lua require('vscode').action('workbench.action.toggleZenMode')<CR>")
map({ "n" }, "<leader>ct", "<cmd>lua require('vscode').action('workbench.action.closeOtherEditors')<CR>")
map({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
map({ "n", "v" }, "<leader>vp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
map({ "n", "v" }, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
map(
	"n",
	"<leader>nf",
	':lua require("vscode").action("filebunny.createFile")<CR>',
	opts
)
map(
	"n",
	"<leader>nF",
	':lua require("vscode").action("filebunny.createFolder")<CR>',
	opts
)
map(
	"n",
	"<leader>lp",
	':lua require("vscode").action("livePreview.start.preview.atFile")<CR>',
	opts
)

-- File Operations
-- map({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
-- map({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
map({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
map({ "n", "v" }, "<leader>w", "<cmd>lua require('vscode').action('workbench.action.files.save')<CR>")
map({ "n", "v" }, "<leader>of", "<cmd>lua require('vscode').action('workbench.action.files.openFile')<CR>", opts)

-- Editor Management
map({ "n", "v" }, "<leader>th", "<cmd>lua require('vscode').action('workbench.action.selectTheme')<CR>")
map({ "n", "v" }, "<leader>x", "<cmd>lua require('vscode').action('workbench.view.extensions')<CR>")
map({ "n", "v" }, "<leader>sk", "<cmd>lua require('vscode').action('workbench.action.openGlobalKeybindings')<CR>")
map({ "n", "v" }, "<leader>q", "<cmd>lua require('vscode').action('workbench.action.closeActiveEditor')<CR>")

-- Split Navigation
map({ "n", "v" }, "<C-h>", "<cmd>lua require('vscode').action('workbench.action.focusEditorLeft')<CR>")
map({ "n", "v" }, "<C-j>", "<cmd>lua require('vscode').action('workbench.action.focusEditorDown')<CR>")
map({ "n", "v" }, "<C-k>", "<cmd>lua require('vscode').action('workbench.action.focusEditorUp')<CR>")
map({ "n", "v" }, "<C-l>", "<cmd>lua require('vscode').action('workbench.action.focusEditorRight')<CR>")
map({ "n", "v" }, "<leader>rw", "<cmd>lua require('vscode').action('workbench.action.reloadWindow')<CR>")
map({ "n", "v" }, "<leader>s", "<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>")
-- make the sidebar close and focus on the file explorer and if pressed space e then closes the file explorer
map(
	"n",
	"<leader>e",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR><cmd>lua require('vscode').action('workbench.files.action.focusFilesExplorer')<CR>"
)
-- make close any side bar
map(
	"n",
	"<leader>gq",
	"<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>",
	{ desc = "Toggle Sidebar" }
)

map(
	"n",
	"<leader>ow",
	'<Cmd>lua require("vscode").action("workbench.action.output.toggleOutput")<CR>',
	opts
)

--[[
=============================================================================
                    Code Navigation and Actions
=============================================================================
--]]
map("n", "<leader>ca", "<cmd>lua require('vscode').action('editor.action.codeAction')<CR>")
map("n", "<leader>cr", "<cmd>lua require('vscode').action('editor.action.rename')<CR>")
map("n", "<leader>cs", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>")
map({ "n", "v" }, "<S-l>", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
map("n", "[d", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>", opts)
map("n", "]d", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>", opts)
map(
	"n",
	"<leader>oc",
	":e $HOME/AppData/Local/nvim/lua/user/vscode_maps.lua<CR>",
	opts
)

map("n", "<leader>vp", function()
	vim.fn.VSCodeNotify("workbench.actions.view.problems")
end)
map("n", "<leader>gr", function()
	require("vscode").action("editor.action.referenceSearch.trigger")
end, { desc = "Show references" })

map("n", "gd", function()
	require("vscode").action("editor.action.revealDefinition")
end, { desc = "Go to definition" })

map("n", "gD", function()
	require("vscode").action("editor.action.peekDefinition")
end, { desc = "Peek definition" })

map("n", "gr", function()
	require("vscode").action("editor.action.referenceSearch.trigger")
end, { desc = "Search references" })
map({ "n", "v" }, "<S-l>", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
map("n", "<leader>gi", function()
	require("vscode").action("editor.action.goToImplementation")
end, { desc = "Go to implementation" })

map("n", "za", function()
	require("vscode").action("editor.toggleFold")
end, { desc = "Toggle fold" })

--[[
=============================================================================
                    Custom Text Operations
=============================================================================
--]]
--
-- Select all content in normal mode
map("n", "<leader>sa", "ggVG", opts) -- Select all

-- Delete all content and store in black hole register
map("n", "<leader>da", 'ggVG"_d', opts) -- Delete all and store in black hole register

-- Yank all content to system clipboard
map("n", "<leader>ya", 'ggVG"+y', opts) -- Yank all to system clipboard

map(
	"n",
	"gft",
	[[:execute "normal! f".nr2char(getchar())."a"<CR>]],
	opts
)
map("n", "<leader>d;", ":s/;$//<CR>", opts)
map("n", "<leader>d,", ":s/,$//<CR>", opts)
map("n", "<leader>;", "mzA;<Esc>`z", opts)
map("n", "<leader>,", "mzA,<Esc>`z", opts)
map("n", "<leader>pr", [[mzOprintln!("{}", );<Esc>hi]], opts)
map("n", "<leader>pr", [[mzOprintln!("{}", );<Esc>hi]], opts)
map(
	"n",
	"<leader>bs",
	[[:%s/\([^\\]\)\\\([^\\]\)/\1\\\\\2/g<CR>]],
	opts
)
map("n", "x", '"qx', opts) -- Fixed closing parenthesis
map('n', '<leader>j', 'mzJ`z', opts)
map('n', '<leader>k', 'kmzJ`z', opts)
map("n", "<leader>n", "o<Esc>", opts)
map("n", "<leader>N", "O<Esc>", opts)
map({ "n", "x", "i" }, "<C-d>", function()
  vscode.with_insert(function()
    vscode.action("editor.action.addSelectionToNextFindMatch")
  end)
end)

--[[
=============================================================================
                    Harpoon Integration
=============================================================================
--]]
map({ "n", "v" }, "<leader>ha", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
map({ "n", "v" }, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
map({ "n", "v" }, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")

for i = 1, 9 do
	map(
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
map({ "n", "v" }, "<leader>pa", "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>")
map({ "n", "v" }, "<leader>po", "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>")
map({ "n", "v" }, "<leader>pe", "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>")

--[[
=============================================================================
                    Plugin Configuration
=============================================================================
--]]
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
			map(
				"n",
				"s",
				'<Cmd>lua require("leap").leap({ target_windows = { vim.fn.win_getid() } })<CR>',
				opts
			)
		end,
	},
	{
		"vscode-neovim/vscode-multi-cursor.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},
})
