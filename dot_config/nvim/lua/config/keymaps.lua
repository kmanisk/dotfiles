-- ================================================================================================
-- TITLE: NeoVim keymaps
-- ABOUT: sets some quality-of-life keymaps
-- ================================================================================================

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Spell Check "Wizard" Mode
-- Press <leader>z to jump to the next error and open the suggestion list instantly
vim.keymap.set("n", "<leader>z", "]sz=", { desc = "Next Spell Suggestion" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- File Explorer
vim.keymap.set("n", "<leader>m", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus on File Explorer" })
vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

-- Toggle Color Hightlighter
vim.keymap.set("n", "<leader>hc", "<cmd>HighlightColorsToggle<CR>", { desc = "Toggle highlight colors" })

-- lua/config/keymaps.lua (add somewhere inside)
--- lua/config/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--------------------------------------------------
-- Center screen when jumping / scrolling
--------------------------------------------------
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "*", "*zzzv", { desc = "Next word match centered" })
map("n", "#", "#zzzv", { desc = "Previous word match centered" })
map("n", "g*", "g*zzzv", { desc = "Next partial match centered" })
map("n", "g#", "g#zzzv", { desc = "Previous partial match centered" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })

map("n", "gg", "ggzz", { desc = "Top centered" })
map("n", "G", "Gzz", { desc = "Bottom centered" })

map("n", "[{", "{zz", { desc = "Previous block centered" })
map("n", "]}", "}zz", { desc = "Next block centered" })

--------------------------------------------------
-- Spell check wizard
--------------------------------------------------
map("n", "<leader>z", "]sz=", { desc = "Next spell suggestion" })

--------------------------------------------------
-- Buffer navigation
--------------------------------------------------
map("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

--------------------------------------------------
-- Window navigation
--------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })

--------------------------------------------------
-- Splitting windows
--------------------------------------------------
map("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Horizontal split" })

--------------------------------------------------
-- Resize windows
--------------------------------------------------
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase width" })

--------------------------------------------------
-- Visual indent keep selection
--------------------------------------------------
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

--------------------------------------------------
-- Move lines up/down
--------------------------------------------------
map("v", "J", ":m .+1<CR>==zz", opts)
map("v", "K", ":m .-2<CR>==zz", opts)
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("x", "K", ":move '<-2<CR>gv-gv", opts)

--------------------------------------------------
-- Join lines without moving cursor
--------------------------------------------------
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })

--------------------------------------------------
-- Clipboard integration
--------------------------------------------------
map("n", "yy", '"+yy', { desc = "Yank line to clipboard" })
map("v", "y", '"+y', { desc = "Yank selection to clipboard" })

map("n", "p", '"+p', { desc = "Paste clipboard" })
map("v", "p", '"_dP', { desc = "Paste without overwriting clipboard" })

map("n", "<leader>d", '"+y', { desc = "Yank to clipboard" })
map("v", "<leader>d", '"+y', { desc = "Yank selection clipboard" })

map("i", "<C-m>", "<C-R>+", { desc = "Paste clipboard insert mode" })

--------------------------------------------------
-- Black hole delete (preserve clipboard)
--------------------------------------------------
map("n", "d", '"_d', opts)
map("n", "dd", '"_dd', opts)
map("v", "d", '"_d', opts)
map("v", "D", '"_D', opts)

--------------------------------------------------
-- Paste helpers
--------------------------------------------------
map("n", "gp", 'o<Esc>"+p', { desc = "Paste below new line" })
map("n", "gP", 'O<Esc>"+P', { desc = "Paste above new line" })

--------------------------------------------------
-- Tabs
--------------------------------------------------
map("n", "<leader>tt", ":tabnew<CR>", { desc = "New tab" })

--------------------------------------------------
-- File explorer
--------------------------------------------------
map("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle explorer" })
map("n", "<leader>m", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus explorer" })

--------------------------------------------------
-- Config editing
--------------------------------------------------
map("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })
map("n", "<leader>sf", ":source %<CR>", { desc = "Source current file" })

--------------------------------------------------
-- New line without insert mode
--------------------------------------------------
map("n", "<leader>n", "o<Esc>", { desc = "New line below" })
map("n", "<leader>N", "O<Esc>", { desc = "New line above" })

--------------------------------------------------
-- Select / Yank / Delete all
--------------------------------------------------
map("n", "<leader>sa", "ggVG", { desc = "Select all" })
map("n", "<leader>da", 'ggVG"_d', { desc = "Delete all" })
map("n", "<leader>ya", 'ggVG"+y', { desc = "Yank all clipboard" })

--------------------------------------------------
-- Save mappings
--------------------------------------------------
map("n", "<Leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<Leader>W", ":wa<CR>", { desc = "Save all files" })

--------------------------------------------------
-- Append / remove semicolons and commas
--------------------------------------------------
map("n", "<leader>d;", ":s/;$//<CR>", { desc = "Remove semicolon" })
map("n", "<leader>d,", ":s/,$//<CR>", { desc = "Remove comma" })

map("n", "<leader>;", "mzA;<Esc>`z", { desc = "Append semicolon" })
map("n", "<leader>,", "mzA,<Esc>`z", { desc = "Append comma" })

--------------------------------------------------
-- Highlight colors toggle
--------------------------------------------------
map("n", "<leader>hc", "<cmd>HighlightColorsToggle<CR>", { desc = "Toggle color highlight" })

--------------------------------------------------
-- Telescope live grep args
--------------------------------------------------
map(
	"n",
	"<leader><leader>",
	":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
	{ desc = "Live grep args" }
) -- manual completion trigger (insert mode)
--------------------------------------------------
-- Exit insert mode with jk
--------------------------------------------------
map("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
map("n", "<leader><tab>", ":q!<CR>")
vim.keymap.set("n", "<leader>bb", ":Telescope buffers<CR>", { desc = "Buffers" })

-- Normal mode movements
map("n", "j", "jzzzv", opts) -- move down and center
map("n", "k", "kzzzv", opts) -- move up and center
map("n", "{", "{zzzv", opts) -- previous paragraph and center
map("n", "}", "}zzzv", opts) -- next paragraph and center
map("n", "[", "[[zzzv", opts) -- previous section and center
map("n", "]", "]]zzzv", opts) -- next section and center

-- Half-page scrolling
map("n", "<C-d>", "<C-d>zzzv", opts) -- page down and center
map("n", "<C-u>", "<C-u>zzzv", opts) -- page up and center

-- Search navigation
map("n", "n", "nzzzv", opts) -- next search result and center
map("n", "N", "Nzzzv", opts) -- previous search result and center
