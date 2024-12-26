require "nvchad.mappings"

-- add yours here
vim.keymap.set("n", "<leader>w", ":w<CR>:!javac % && java %<CR>", { desc = "Save and run Java" })

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- for vscode to work with keymaps

-- Keymap to quit Neovim with <leader>q
vim.api.nvim_set_keymap('n', '<leader>Q', ':qa!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':q!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- Center screen after scrolling up with Ctrl + u
vim.api.nvim_set_keymap("n" , "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Map 'jk' to escape insert mode
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Map 'jk' to escape command-line mode
vim.api.nvim_set_keymap("c", "jk", "<C-c>", { noremap = true, silent = true })

vim.keymap.set("n", "<Tab>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous Buffer" })

-- Keybindings for opening and closing buffers
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { noremap = true, silent = true, desc = "New Buffer" }) -- Open a new buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { noremap = true, silent = true, desc = "Delete Buffer" }) -- Close the current buffer

--Atl V to get in Block visual mode as ctrl v is binded in windows 
vim.keymap.set('n', '<A-v>', '<C-v>')

-- Yank to system clipboard only when using these mappings
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true })  -- Visual mode
vim.api.nvim_set_keymap('n', '<leader>gy', '"+y', { noremap = true, silent = true })  -- Normal mode

-- Paste from system clipboard only with these mappings
vim.api.nvim_set_keymap('n', '<leader>gp', '"+p', { noremap = true, silent = true })  -- Normal mode
vim.api.nvim_set_keymap('i', '<C-p>', '<C-r>+', { noremap = true, silent = true })   -- Insert mode using Ctrl+P


-- In Insert mode
vim.api.nvim_set_keymap('i', '<C-CR>', '<C-o>o', { noremap = true, silent = true })


-- Custom Key Mappings
vim.api.nvim_set_keymap('n', '<leader>k', '"+gy', { noremap = true, silent = true }) -- Yank to clipboard
vim.api.nvim_set_keymap('n', '<leader>l', '"+gp', { noremap = true, silent = true }) -- Paste from clipboard

-- Key Mappings for Neovim
vim.api.nvim_set_keymap("n", "<leader>sa", "ggVG", { noremap = true, silent = true }) -- Select all
vim.api.nvim_set_keymap("n", "<leader>ya", "ggVGd\"+p", { noremap = true, silent = true }) -- Yank all to system clipboard
vim.api.nvim_set_keymap("n", "<leader>da", "ggVGd", { noremap = true, silent = true }) -- Delete all
vim.api.nvim_set_keymap('n', '<leader>d;', ':s/;$//<CR>', { noremap = true, silent = true }) -- Remove trailing semicolons
vim.api.nvim_set_keymap('n', '<leader>d,', ':s/,$//<CR>', { noremap = true, silent = true }) -- Remove trailing commas
vim.api.nvim_set_keymap('n', '<leader>;', 'mzA;<Esc>`z', { noremap = true, silent = true }) -- Append semicolon at the end
vim.api.nvim_set_keymap('n', '<leader>,', 'mzA,<Esc>`z', { noremap = true, silent = true }) -- Append comma at the end
vim.api.nvim_set_keymap('n', '<leader>pr', [[mzOprintln!("{}", );<Esc>hi]], { noremap = true, silent = true }) -- Insert a `println!` statement (Rust)
vim.api.nvim_set_keymap('n', '<leader>bs', [[:%s/\([^\\]\)\\\([^\\]\)/\1\\\\\2/g<CR>]], { noremap = true, silent = true }) -- Escape backslashes correctly
vim.api.nvim_set_keymap('n', 'x', '"qx', { noremap = true, silent = true }) -- Delete and store in register q
vim.api.nvim_set_keymap('n', '<leader>j', 'J', { noremap = true, silent = true }) -- Join lines with <leader>j
vim.api.nvim_set_keymap('n', '<leader>k', 'kJ', { noremap = true, silent = true }) -- Move up and join line with <leader>k
vim.api.nvim_set_keymap("n", "<leader>n", "o<Esc>", { noremap = true, silent = true }) -- Create a new line below without entering insert mode
vim.api.nvim_set_keymap("n", "<leader>N", "O<Esc>", { noremap = true, silent = true }) -- Create a new line above without entering insert mode
vim.api.nvim_set_keymap('v', 'y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'yy', '"+yy', { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gp', 'o<Esc>"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gP', 'O<Esc>"+P', { noremap = true, silent = true })
-- Define options for the key mappings
local opts = { noremap = true, silent = true }
-- Visual mode: Move selected lines down
vim.api.nvim_set_keymap("v", "J", ":m .+1<CR>==", opts)

-- Visual mode: Move selected lines up
vim.api.nvim_set_keymap("v", "K", ":m .-2<CR>==", opts)
-- Map Leader + v to set filetype to vim and enable syntax highlighting
vim.api.nvim_set_keymap("n", "<leader>so", ":set filetype=vim<CR>", { noremap = true, silent = true })


-- Visual block mode: Move selected block down
vim.api.nvim_set_keymap("x", "J", ":move '>+1<CR>gv-gv", opts)

-- Visual block mode: Move selected block up
vim.api.nvim_set_keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
-- Map 'U' to redo
vim.api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true, silent = true })

-- Map '<leader>u' to the original 'U' functionality (undo changes on a single line)
vim.api.nvim_set_keymap("n", "<leader>u", "U", { noremap = true, silent = true })


-- Map '<leader>w' to ':w' (save the current buffer)
vim.api.nvim_set_keymap("n", "<leader>w", ":w<CR>", { noremap = true, silent = true })
-- Map 'Shift+j' to move to the previous buffer
vim.api.nvim_set_keymap("n", "J", ":bprev<CR>", { noremap = true, silent = true })

-- Map 'Shift+k' to move to the next buffer
vim.api.nvim_set_keymap("n", "K", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", "", { noremap = true })      -- Unbind Tab
vim.keymap.set("n", "<S-Tab>", "", { noremap = true })    -- Unbind Shift-Tab
vim.api.nvim_set_keymap("n", "<leader>t", ":enew<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Leader t to open a new buffer
keymap('n', '<leader>t', ':enew<CR>', opts)

-- Leader q to close the current buffer
-- keymap('n', '<leader>q', ':bd<CR>', opts)


-- Map leader+r+f to run code
vim.api.nvim_set_keymap('n', '<Leader>rf', ':lua run_code()<CR>', { noremap = true, silent = true })

-- Function to run code based on file type
function run_code()
  -- Auto save the current file before running the code
  vim.cmd("w")

  -- Ask user for a custom command (or use the default based on filetype)
  local user_command = vim.fn.input("Enter the command (or press Enter to use default): ")

  -- Get the filetype, file name, and file name without extension
  local ft = vim.bo.filetype
  local file = vim.fn.expand('%')
  local file_without_ext = vim.fn.expand('%:r')
  local cmd = ""

  -- If user input is not empty, use their command
  if user_command ~= "" then
    cmd = user_command
  else
    -- Use default commands based on the file type
    if ft == "javascript" then
      cmd = "node " .. file
    elseif ft == "java" then
      cmd = "javac " .. file .. " && java " .. file_without_ext
    elseif ft == "python" then
      cmd = "python " .. file
    elseif ft == "c" then
      cmd = "gcc " .. file .. " -o " .. file_without_ext .. " && ./" .. file_without_ext
    elseif ft == "cpp" then
      cmd = "g++ " .. file .. " -o " .. file_without_ext .. " && ./" .. file_without_ext
    elseif ft == "go" then
      cmd = "go run " .. file
    elseif ft == "rust" then
      cmd = "cargo run"
    -- Add other languages here as necessary
    else
      print("No executor found for this filetype")
      return
    end
  end

  -- Run the final command
  vim.cmd("! " .. cmd)
end

vim.keymap.set("n", "<leader>fm", ":Vifm<CR>", { desc = "Open Vifm" })
vim.keymap.set("n", "<leader>vf", ":VifmCurrentFile<CR>", { desc = "Open Vifm with current file" })

---@type MappingsTable
local M = {}

-- Define general key mappings
M.general = {
    -- Normal mode
    n = {
        ["yy"] = { '"+yy', "Yank line to system clipboard" },
        ["gp"] = { '"+p', "Paste from system clipboard" },
        ["gP"] = { '"+P', "Paste before cursor from system clipboard" },
    },

    -- Visual mode
    v = {
        ["y"] = { '"+y', "Yank selection to system clipboard" },
        ["<leader>y"] = { '"+y', "Yank to system clipboard (leader)" },
        ["p"] = { '"+p', "Paste from system clipboard" },
        ["J"] = { ":m .+1<CR>==", "Move line down" },
        ["K"] = { ":m .-2<CR>==", "Move line up" },
    },

    -- Visual Block mode
    x = {
        ["J"] = { ":move '>+1<CR>gv-gv", "Move block down" },
        ["K"] = { ":move '<-2<CR>gv-gv", "Move block up" },
    },
}

return M











 

