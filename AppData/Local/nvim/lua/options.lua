-- Load default NvChad options first
require("nvchad.options")

-- Basic settings
local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- Enable line numbers and relative line numbers
o.number = true
o.relativenumber = true

-- vim.o.shell = "pwsh"
-- vim.o.shellcmdflag = "-NoExit -Command"
-- Enable smart case for search (case-insensitive unless you use uppercase letters)
o.smartcase = true
o.ignorecase = true

-- Enable cursorline (highlight the line where the cursor is)
wo.cursorline = true

-- Enable search highlighting
o.hlsearch = true

-- Enable line wrapping for long lines
o.wrap = true -- Set to false for no wrap, true for wrapping

-- Enable smart indentation (for auto indent)
o.smartindent = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true -- Converts tabs to spaces
o.autoindent = true

-- Enable line break at word boundary
o.linebreak = true

-- Set the cursor type (e.g., block, vertical bar, underline)
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Set clipboard to use the system clipboard (only if supported)
o.clipboard = "unnamedplus" -- Allows use of system clipboard for copy-paste

-- Set background (dark or light)
o.background = "dark" -- or "light"

-- Ensure window options are modifiable before making changes
if vim.bo.modifiable then
	-- Example buffer-specific options (only if the buffer is modifiable)
	bo.textwidth = 80 -- Example option
end
