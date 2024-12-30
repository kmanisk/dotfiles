-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable powershell as your default shell
-- 
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
lvim.leader = "space"
vim.opt.shell = "pwsh.exe"
vim.opt.relativenumber = true
vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, vim.api.nvim_create_namespace "auto_hlsearch")
-- Map ESC to clear search highlights
map("n", "<Esc>", ":noh<CR><Esc>", opts)  -- Clears highlights and then goes back to normal mode

-- key_map("n", "<C-s>", "", {
--     callback = function()
--         if not vim.o.hlsearch then
--             vim.o.hlsearch = true
--         else
--             vim.o.hlsearch = false
--         end
--     end,
--     noremap = true,
--     silent = true,
--     desc = "Toggle hlsearch mode.",
-- })
-- Basic settings
local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- Enable line numbers and relative line numbers
o.number = true
o.relativenumber = true

-- Enable smart case for search (case-insensitive unless you use uppercase letters)
o.smartcase = true
o.ignorecase = true

-- Enable cursorline (highlight the line where the cursor is)
wo.cursorline = true

-- Enable search highlighting
o.hlsearch = true

-- Enable line wrapping for long lines
o.wrap = false -- Set to false for no wrap, true for wrapping

-- Enable smart indentation (for auto indent)
o.smartindent = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true -- Converts tabs to spaces
o.autoindent = true

-- Enable line break at word boundary
o.linebreak = true
vim.keymap.set('i','jk','<Esc>')
vim.keymap.set('n','<leader>n','o<Esc>')
-- lvim.builtin.nvimtree.active = false -- NOTE: using neo-tree
vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=
  ]]

  -- Centers cursor when moving 1/2 page down
  lvim.keys.normal_mode["<C-u>"] = "<C-u>zz"
  lvim.keys.normal_mode["<C-d>"] = "<C-d>zz"
-- Centers cursor when moving between paragraphs with `{` and `}`
lvim.keys.normal_mode["{"] = "{zz"
lvim.keys.normal_mode["}"] = "}zz"
-- Custom mappings
map("n", "<leader>fm", ":Vifm<CR>", { desc = "Open Vifm" })
map("n", "<S-j>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-k>", ":bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<Leader>t", ":enew<CR>", { desc = "Open a new tab" })
map("n", "<leader>j", "J")
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("v", "J", ":m .+1<CR>==", opts)
map("v", "K", ":m .-2<CR>==", opts)
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("x", "K", ":move '<-2<CR>gv-gv", opts)
-- Vertical split with Alt + v
vim.api.nvim_set_keymap("n", "<A-v>", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical split" })

-- Horizontal split with Alt + h
vim.api.nvim_set_keymap("n", "<A-h>", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal split" })

-- Close current split with Alt + w
vim.api.nvim_set_keymap("n", "<A-w>", ":close<CR>", { noremap = true, silent = true, desc = "Close current split" })

-- Remove trailing semicolons and commas, and append semicolons and commas at the end
map("n", "<leader>d;", ":s/;$//<CR>", { noremap = true, silent = true, desc = "Remove trailing semicolons" })
map("n", "<leader>d,", ":s/,$//<CR>", { noremap = true, silent = true, desc = "Remove trailing commas" })
map("n", "<leader>;", "mzA;<Esc>`z", { noremap = true, silent = true, desc = "Append semicolon at the end" })
map("n", "<leader>,", "mzA,<Esc>`z", { noremap = true, silent = true, desc = "Append comma at the end" })



-- Set a compatible clipboard manager
vim.g.clipboard = {
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
}

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

-- Select all
vim.api.nvim_set_keymap("n", "<leader>sa", "ggVG", { noremap = true, silent = true }) -- Select all
vim.api.nvim_set_keymap("n", "<leader>da", "ggVGd", { noremap = true, silent = true }) -- Delete all

-- Yank all to system clipboard
vim.api.nvim_set_keymap("n", "<leader>ya", 'ggVG"+p', { noremap = true, silent = true }) -- Yank all to system clipboard
local builtin = require("telescope.builtin")
vim.keymap.set(
	"n",
	"<leader>th",
	":Telescope colorscheme<CR>",
	{ noremap = true, silent = true, desc = "Choose colorscheme with Telescope" }
)



map("n", "<leader>fm", ":Vifm<CR>", { desc = "Open Vifm" })
-- Map 'jk' to 'zz' in normal mode
map("n", "j", "jzz", { noremap = true, silent = true })
map("n", "k", "kzz", { noremap = true, silent = true })
-- Remove the default mapping for <leader>f
-- lvim.builtin.which_key.mappings['f'] = nil
--vim.keymap.set('n', '<leader>rr', ':RunCode<CR>', { noremap = true, silent = false })
map('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
map('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
map('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
map('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
map('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
map('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })

-- plugins
--
lvim.plugins = {
  {'ThePrimeagen/vim-be-good'},
  {'vifm/vifm.vim'},
  {
    "ggandor/leap.nvim",
    name = "leap",
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  {
    "nacro90/numb.nvim",
    event = "BufRead",
    config = function()
      require("numb").setup({
        show_numbers = true, -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      })
    end,
  },
  {
    "CRAG666/code_runner.nvim",
    config = function()
      require('code_runner').setup({
term = {
    size = 10,  -- Terminal size (smaller terminal window)
  },
  float = {
    width = 0.6,  -- 60% width
    height = 0.3, -- 30% height
    border = "rounded",  -- Optional: rounded border for the float window
  },
        filetype = {
          java = {
            "cd $dir &&",
            "javac $fileName &&",
            "java $fileNameWithoutExt"
          },
          python = "python3 -u",
          typescript = "deno run",
          rust = {
            "cd $dir &&",
            "rustc $fileName &&",
            "$dir/$fileNameWithoutExt"
          },
          c = function(...)
            local c_base = {
              "cd $dir &&",
              "gcc $fileName -o",
              "/tmp/$fileNameWithoutExt",
            }
            local c_exec = {
              "&& /tmp/$fileNameWithoutExt &&",
              "rm /tmp/$fileNameWithoutExt",
            }
            vim.ui.input({ prompt = "Add more args:" }, function(input)
              c_base[4] = input
              vim.print(vim.tbl_extend("force", c_base, c_exec))
              require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
            end)
          end,
        },
      })
    end,
  },
}
