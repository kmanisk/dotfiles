-- Using <leader> + number (1, 2, ... 9) to switch tabmap
-- Define map function for convenience
local map = vim.keymap.set

-- map for quick quit, save files using leader key
---- Normal mode
map("n", "<Leader>a", ":wqa<CR>")
-- map("n", "<Leader>x", ":wq<CR>")

---- Insert mode
map("i", ";w", "<esc>:write<CR>")
map("i", ";x", "<esc>:wq<CR>")
-- use U for redo :))
map("n", "U", "<C-r>", {})

-- Telescope key mapping
map("n", "<leader>ff", "<cmd>Telescope<cr>", { desc = "Open Telescope" })

-- Multiple modes
map({ "i", "n" }, "<C-k>", "<Up>", { desc = "Move up" })
map({ "i", "n" }, "<C-j>", "<Down>", { desc = "Move down" })

-- Mapping with a Lua function

-- Force quit Neovim
map("n", "<Leader><Tab>", ":qa!<CR>", { noremap = true, silent = true, desc = "Force quit Neovim" })

-- Move focus between panes
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left pane" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to the bottom pane" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to the top pane" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right pane" })

-- Close the current tab with Ctrl+w
map("n", "<C-w>", ":tabclose<CR>", { desc = "Close current tab" })

-- Remove trailing semicolons and commas, and append semicolons and commas at the end
map("n", "<leader>d;", ":s/;$//<CR>", { noremap = true, silent = true, desc = "Remove trailing semicolons" })
map("n", "<leader>d,", ":s/,$//<CR>", { noremap = true, silent = true, desc = "Remove trailing commas" })
map("n", "<leader>;", "mzA;<Esc>`z", { noremap = true, silent = true, desc = "Append semicolon at the end" })
map("n", "<leader>,", "mzA,<Esc>`z", { noremap = true, silent = true, desc = "Append comma at the end" })

-- Map Ctrl+d to scroll down with centering
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })

-- Map Ctrl+u to scroll up with centering
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
-- Map <leader>ls to run :Lazy sync
map("n", "<leader>Ls", ":Lazy sync<CR>", { noremap = true, silent = true, desc = "Sync lazy plugins" })

-- Select all
vim.api.nvim_set_keymap("n", "<leader>sa", "ggVG", { noremap = true, silent = true }) -- Select all
vim.api.nvim_set_keymap("n", "<leader>da", "ggVGd", { noremap = true, silent = true }) -- Delete all

-- Yank all to system clipboard
vim.api.nvim_set_keymap("n", "<leader>ya", 'ggVG"+p', { noremap = true, silent = true }) -- Yank all to system clipboard

-- Custom mappings
map("n", "<S-j>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-k>", ":bprevious<CR>", { desc = "Previous Buffer" })

vim.keymap.set(
	"n",
	"<leader>ff",
	":Telescope find_files<CR>",
	{ noremap = true, silent = true, desc = "Find files with Telescope" }
)

vim.keymap.set(
	"n",
	"<leader>th",
	":Telescope colorscheme<CR>",
	{ noremap = true, silent = true, desc = "Choose colorscheme with Telescope" }
)
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })

vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

map("n", "<leader>fj", ':lua print("asdfasdfafds")<CR>', { noremap = true, silent = true })
