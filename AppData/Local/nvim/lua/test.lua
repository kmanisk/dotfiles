local map = vim.keymap.set

map("n", "<leader>ff", "<cmd> Telescope <cr>")

-- multiple modes
map({ "i", "n" }, "<C-k>", "<Up>", { desc = "Move up" })
map({ "i", "n" }, "<C-j>", "<Down>", { desc = "Move down" })

-- mapping with a lua function
map("n", "<A-i>", function()
	-- do something
end, { desc = "Terminal toggle floating" })

--
map("n", "<Leader><Tab>", ":qa!<CR>", { noremap = true, silent = true, desc = "Force quit Neovim" })

-- Move focus between panes
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left pane" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to the bottom pane" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to the top pane" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right pane" })

-- Close the current tab with Ctrl+w
map("n", "<C-w>", ":tabclose<CR>", { desc = "Close current tab" })

-- Save current file with Leader+w
map("n", "<Leader>w", ":w<CR>", { desc = "Save current file" })

-- Save all files with Leader+W

-- Remove trailing semicolons and commas, and append semicolons and commas at the end
map("n", "<leader>d;", ":s/;$//<CR>", { noremap = true, silent = true, desc = "Remove trailing semicolons" })
map("n", "<leader>d,", ":s/,$//<CR>", { noremap = true, silent = true, desc = "Remove trailing commas" })
map("n", "<leader>;", "mzA;<Esc>`z", { noremap = true, silent = true, desc = "Append semicolon at the end" })
map("n", "<leader>,", "mzA,<Esc>`z", { noremap = true, silent = true, desc = "Append comma at the end" })

-- Map Ctrl+d to scroll down with centering
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })

-- Map Ctrl+u to scroll up with centering
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Yank to system clipboard in normal and visual mode
map("v", "y", '"+y', { noremap = true, silent = true })
map("n", "yy", '"+yy', { noremap = true, silent = true })
map("n", "p", '"+p', { noremap = true, silent = true })
map("v", "<leader>y", '"+y', { noremap = true, silent = true })
map("v", "p", '"+p', { noremap = true, silent = true })

-- Paste from system clipboard with specific behavior
map("n", "gp", 'o<Esc>"+p', { noremap = true, silent = true })
map("n", "gP", 'O<Esc>"+P', { noremap = true, silent = true })
-- Prevent content from being placed in clipboard when deleting (use black hole register)
map("n", "d", '"_d', { noremap = true, silent = true })
map("n", "dd", '"_dd', { noremap = true, silent = true })
map("v", "d", '"_d', { noremap = true, silent = true })
map("v", "D", '"_D', { noremap = true, silent = true })
-- Map <Leader>d to yank to clipboard
map("n", "<Leader>d", '"+y', { noremap = true, silent = true })
map("v", "<Leader>d", '"+y', { noremap = true, silent = true })

-- Replace paste with black hole register
map("v", "p", '"_dP', { noremap = true, silent = true })

-- Map [{ and ]} to center the screen after jumping
map("n", "[{", "{zz", { noremap = true, silent = true, desc = "Jump to previous block and center" })
map("n", "]}", "}zz", { noremap = true, silent = true, desc = "Jump to next block and center" })

-- Map <leader>ls to run :Lazy sync
-- map("n", "<leader>ls", ":Lazy sync<CR>", { noremap = true, silent = true, desc = "Sync lazy plugins" })

map("n", "<leader><leader>", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
-- Map Ctrl+; to toggle the terminal
---jtest
---

vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<A-q>", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })

local builtin = require("telescope.builtin")

-- Set the keymap for searching Neovim configuration files
vim.keymap.set("n", "<leader>oc", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

-- Map <leader>cg to live grep within Neovim config directory
vim.api.nvim_set_keymap(
	"n",
	"<leader>og",
	':lua require("telescope.builtin").live_grep({ cwd = vim.fn.stdpath("config") })<CR>',
	{ noremap = true, silent = true, desc = "[C]onfig [G]rep" }
)
