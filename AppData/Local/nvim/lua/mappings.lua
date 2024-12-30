require("nvchad.mappings")

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
--

-- Map 'jk' to 'zz' in normal mode
map("n", "j", "jzz", { noremap = true, silent = true })
map("n", "k", "kzz", { noremap = true, silent = true })
-- Custom mappings
map("n", "<leader>fm", ":Vifm<CR>", { desc = "Open Vifm" })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
map("n", "<A-d>", ":NvimTreeClose<CR>", { desc = "Close NvimTree" })
map("n", "<S-j>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-k>", ":bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<Leader>t", ":enew<CR>", { desc = "Open a new tab" })
map("n", "<leader>q", ":bdelete<CR>", { desc = "Close the buffer" })
map("n", "<leader>j", "J")
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("v", "J", ":m .+1<CR>==", opts)
map("v", "K", ":m .-2<CR>==", opts)
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Remove default mappings
local nomap = vim.keymap.del
nomap("n", "<leader>h")
nomap("n", "<leader>v")
nomap("n", "<leader>x")
nomap("n", "<space>wk")
nomap("n", "<space>wK")
nomap("n", "<Tab>")
nomap("n", "<S-Tab>")
-- nomap("n", "<M-i>")
-- nomap("n", "<M-v>")

-- Vertical split with Alt + v

vim.api.nvim_set_keymap("n", "<A-V>", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical split" })

-- Horizontal split with Alt + h
vim.api.nvim_set_keymap("n", "<A-h>", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal split" })

-- Close current split with Alt + w
vim.api.nvim_set_keymap("n", "<A-w>", ":close<CR>", { noremap = true, silent = true, desc = "Close current split" })

-- Map Ctrl + ; to toggle the terminal

vim.keymap.set("n", "<leader>sk", function()
	require("telescope.builtin").keymaps()
end, { desc = "Telescope Keymaps" })

vim.api.nvim_set_keymap("n", "<leader>bb", ":lua InputCommand()<CR>", { noremap = true, silent = true })

function InputCommand()
	local command = vim.fn.input("Shell command: ")
	vim.cmd("!" .. command)
end
return {} -- Ensure this file returns a table
