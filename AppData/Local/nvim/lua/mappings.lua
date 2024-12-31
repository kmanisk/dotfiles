require("nvchad.mappings")

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
--

-- For nvim-cmp or other completion plugins
vim.api.nvim_set_keymap("i", "<C-y>", "cmp.mapping.confirm({ select = true })", { noremap = true, silent = true })
-- Map 'jk' to 'zz' in normal mode
map("n", "j", "jzz", { noremap = true, silent = true })
map("n", "k", "kzz", { noremap = true, silent = true })
-- Custom mappings
map("n", "<leader>fm", ":Vifm<CR>", { desc = "Open Vifm" })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
map("n", "<A-d>", ":NvimTreeClose<CR>", { desc = "Close NvimTree" })
map("n", "<S-j>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-k>", ":bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<leader>j", "J")
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("v", "J", ":m .+1<CR>==", opts)
map("v", "K", ":m .-2<CR>==", opts)
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("x", "K", ":move '<-2<CR>gv-gv", opts)

-- -- Remove default mappings
-- local nomap = vim.keymap.del
-- -- removed htoggleTerm
-- nomap("n", "<leader>h")
-- -- removed vtoggleTerm
-- nomap("n", "<leader>v")
-- nomap("n", "<leader>b")
-- nomap("n", "<leader>x")
-- nomap("n", "<C-n>")
-- nomap("n", "<space>wk")
-- nomap("n", "<space>n")
-- nomap("n", "<space>wK")
-- nomap("n", "<Tab>")
-- nomap("n", "<S-Tab>")
-- nomap("n", "<A-v>")
-- nomap("n", "<A-i>")
-- nomap("t", "<C-x>")
-- nomap("n", "<leader>rn")
-- nomap("n", "<M-i>")
-- nomap("n", "<M-v>")
--
--
local nomap = vim.keymap.del

-- Function to safely remove a keymap if it exists
local function safe_remove_keymap(mode, key)
	if vim.fn.maparg(key, mode) ~= "" then
		nomap(mode, key)
	end
end

-- Remove default mappings
safe_remove_keymap("n", "<leader>h")
safe_remove_keymap("n", "<leader>v")
safe_remove_keymap("n", "<leader>b")
safe_remove_keymap("n", "<leader>x")
safe_remove_keymap("n", "<C-n>")
safe_remove_keymap("n", "<space>wk")
safe_remove_keymap("n", "<space>n")
safe_remove_keymap("n", "<space>wK")
safe_remove_keymap("n", "<Tab>")
safe_remove_keymap("n", "<S-Tab>")
safe_remove_keymap("n", "<A-v>")
safe_remove_keymap("n", "<A-i>")
safe_remove_keymap("t", "<C-x>")
safe_remove_keymap("n", "<leader>rn")
-- safe_remove_keymap("n", "<M-i>")
-- safe_remove_keymap("n", "<M-v>")
vim.api.nvim_set_keymap("n", "<S-Right>", ":vertical resize +5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Left>", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Down>", ":resize +5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Up>", ":resize -5<CR>", { noremap = true, silent = true })

-- overrided keymaps by from the base nvchad
map("n", "<leader>q", function()
	require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

vim.keymap.set(
	"n",
	"<leader>fh",
	":Telescope oldfiles<CR>",
	{ noremap = true, silent = true, desc = "Search Previous Files" }
)
-- Keybinding to resume the last Telescope search
vim.keymap.set(
	"n",
	"<leader>fr",
	":Telescope resume<CR>",
	{ noremap = true, silent = true, desc = "Resume Last Telescope Search" }
)
vim.keymap.set({ "n", "t" }, "<A-;>", function()
	require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "Toggle terminal horizontally" })
vim.api.nvim_set_keymap("n", "<A-v>", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical split" })

-- Horizontal split with Alt + h
vim.api.nvim_set_keymap("n", "<A-h>", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal split" })

-- Close current split with Alt + w
vim.api.nvim_set_keymap("n", "<A-w>", ":close<CR>", { noremap = true, silent = true, desc = "Close current split" })

vim.keymap.set("n", "<leader>sk", function()
	require("telescope.builtin").keymaps()
end, { desc = "Telescope Keymaps" })

vim.api.nvim_set_keymap("n", "<leader>bb", ":lua InputCommand()<CR>", { noremap = true, silent = true })

function InputCommand()
	local command = vim.fn.input("Shell command: ")
	vim.cmd("!" .. command)
end

-- map({ "n", "t" }, "<A-i>", function()
-- 	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
-- end, { desc = "terminal toggle floating term" })

-- Yank to system clipboard in normal and visual mode
-- map("v", "y", '"+y', { noremap = true, silent = true })
-- map("n", "yy", '"+yy', { noremap = true, silent = true })
-- map("n", "p", '"+p', { noremap = true, silent = true })
-- map("v", "<leader>y", '"+y', { noremap = true, silent = true })
-- map("v", "p", '"+p', { noremap = true, silent = true })
--
-- -- Paste from system clipboard with specific behavior
-- map("n", "gp", 'o<Esc>"+p', { noremap = true, silent = true })
-- map("n", "gP", 'O<Esc>"+P', { noremap = true, silent = true })
-- "asdfasfy"
-- -- Prevent content from being placed in clipboard when deleting (use black hole register)
-- map("n", "d", '"_d', { noremap = true, silent = true })
-- map("n", "dd", '"_dd', { noremap = true, silent = true })
-- map("v", "d", '"_d', { noremap = true, silent = true })
-- map("v", "D", '"_D', { noremap = true, silent = true })
--
-- -- Map <Leader>d to yank to clipboard
-- map("n", "<Leader>d", '"+y', { noremap = true, silent = true })
-- map("v", "<Leader>d", '"+y', { noremap = true, silent = true })
--
-- -- Replace paste with black hole register
-- map("v", "p", '"_dP', { noremap = true, silent = true })
--
--
-- Yank to system clipboard for any 'y' and '<Leader>d' mappings
map("v", "y", '"+y', { noremap = true, silent = true }) -- Visual mode yank to clipboard
map("n", "yy", '"+yy', { noremap = true, silent = true }) -- Normal mode double 'yy' to clipboard
map("n", "p", '"+p', { noremap = true, silent = true }) -- Paste from system clipboard
-- map("v", "<leader>y", '"+y', { noremap = true, silent = true }) -- Yank with <Leader> to clipboard
map("v", "p", '"+p', { noremap = true, silent = true }) -- Paste from clipboard in visual mode

-- Special handling for paste operations with specific behavior
map("n", "gp", 'o<Esc>"+p', { noremap = true, silent = true }) -- Paste in new line after cursor
map("n", "gP", 'O<Esc>"+P', { noremap = true, silent = true }) -- Paste in new line before cursor

-- Prevent content from being placed in clipboard when deleting, use black hole register
map("n", "d", '"_d', { noremap = true, silent = true }) -- Delete in normal mode without affecting clipboard
map("n", "dd", '"_dd', { noremap = true, silent = true }) -- Delete whole line without clipboard
map("v", "d", '"_d', { noremap = true, silent = true }) -- Delete in visual mode without clipboard
map("v", "D", '"_D', { noremap = true, silent = true }) -- Delete to the end of line without clipboard

-- Map <Leader>d to yank to system clipboard
map("n", "<Leader>d", '"+y', { noremap = true, silent = true }) -- Leader+d for system clipboard
map("v", "<Leader>d", '"+y', { noremap = true, silent = true }) -- Leader+d for system clipboard in visual mode

-- Replace paste with black hole register (paste the last delete)
map("v", "p", '"_dP', { noremap = true, silent = true }) -- Replace paste with black hole register

-- Select all content in normal mode
vim.api.nvim_set_keymap("n", "<leader>sa", "ggVG", { noremap = true, silent = true }) -- Select all

-- Delete all content and store in black hole register
vim.api.nvim_set_keymap("n", "<leader>da", 'ggVG"_d', { noremap = true, silent = true }) -- Delete all and store in black hole register

-- Yank all content to system clipboard
vim.api.nvim_set_keymap("n", "<leader>ya", 'ggVG"+y', { noremap = true, silent = true }) -- Yank all to system clipboard

-- Source the current file using <leader>sf
vim.api.nvim_set_keymap("n", "<leader>sf", ":source %<CR>", { noremap = true, silent = true })

-- Create a new line below and return to normal mode
vim.api.nvim_set_keymap("n", "<leader>n", "o<Esc>", { noremap = true, silent = true })

-- Create a new line above and return to normal mode
vim.api.nvim_set_keymap("n", "<leader>N", "O<Esc>", { noremap = true, silent = true })

-- Map 'n' to search forward and center the result on the screen
vim.api.nvim_set_keymap("n", "n", "nzz", { noremap = true, silent = true })

-- Map 'N' to search backward and center the result on the screen
map("n", "N", "Nzz", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "b", "ggVG", { noremap = true, silent = true })
map("i", "<c-i>", '"+p', { noremap = true, silent = true })
vim.cmd("highlight Search ctermbg=235 ctermfg=214 guibg=#dcdcdc guifg=#e1c16e")
