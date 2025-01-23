-- Load default NvChad options first
require("nvchad.options")

-- Basic settings
local o = vim.o
local wo = vim.wo
local bo = vim.bo
local fn = vim.fn

-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFD700", bold = true, font = "Bigger" })
-- vim.opt.laststatus = 1  -- Disable statusline
-- Enable line numbers and relative line numbers
o.number = true
o.relativenumber = true
-- o.swapfile = false
-- vim.opt.showtabline = 0

-- Set shell to pwsh or fallback to powershell
if fn.executable("pwsh") == 1 then
    o.shell = "pwsh"
    o.shellcmdflag =
    "-NoLogo -NoProfile  -ExecutionPolicy RemoteSigned -Command $PSStyle.OutputRendering = 'PlainText';"
else
    o.shell = "powershell"
    o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
end

-- Configure shell output redirection
o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
o.shellquote = ""
o.shellxquote = ""
-- Enable smart case for search (case-insensitive unless you use uppercase letters)
o.smartcase = true
o.ignorecase = true

-- Enable cursorline (highlight the line where the cursor is)
--
vim.opt.cursorline = true -- Highlight the current line

-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2c2c2c", underline = false })
-- wo.cursorline = true

-- Enable search highlighting
-- vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Enable line wrapping for long lines
o.wrap = true -- Set to false for no wrap, true for wrapping

-- Enable smart indentation (for auto indent)
--
--
-- Disable ShaDa file (session data)
vim.o.shada = ""

-- Disable swap files
vim.opt.swapfile = false
-- vim.opt.backup = false

-- Disable backup files

-- Set these options in Lua config
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level

-- Indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
-- Highlight the current line
vim.opt.cursorline = true
-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#333333" })
-- vim.opt.expandtab = true   -- Convert tabs to spaces

vim.opt.smartindent = true -- Enable automatic indentation
vim.opt.autoindent = true  -- Auto-indent new lines
-- Enable line break at word boundary
o.linebreak = true

-- Set the cursor type (e.g., block, vertical bar, underline)
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Set clipboard to use the system clipboard (only if supported)
o.clipboard = "unnamedplus" -- Allows use of system clipboard for copy-paste
-- Animation speed adjustments
vim.g.neovide_animation_fps = 100  -- Increase FPS for faster animations
vim.g.neovide_scroll_animation_length = 0.3  -- Faster scroll animations
vim.g.neovide_cursor_animation_length = 0.05  -- Faster cursor animations
vim.g.neovide_cursor_trail_size = 0.5  -- Smaller cursor trail
-- Set JetBrains Nerd Font with a specific size
vim.o.guifont = "JetBrainsMono Nerd Font:h14"  -- Replace with desired size (e.g., 14)
-- Set background (dark or light)
o.background = "dark" -- or "light"

vim.opt.linespace = 9  -- Adjust the line spacing; increase the value for more space between lines
-- Ensure window options are modifiable before making changes
if bo.modifiable then
    -- Example buffer-specific options (only if the buffer is modifiable)
    bo.textwidth = 100 -- Example option
end
