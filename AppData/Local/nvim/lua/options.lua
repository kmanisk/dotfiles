-- Load default NvChad options first
require("nvchad.options")

-- Basic settings
local o = vim.o
local wo = vim.wo
local bo = vim.bo
local fn = vim.fn

-- vim.opt.laststatus = 1  -- Disable statusline

-- Enable line numbers and relative line numbers
o.number = true
o.relativenumber = true
-- o.swapfile = false

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
wo.cursorline = true

-- Enable search highlighting
vim.opt.hlsearch = false
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

-- Disable backup files


-- Set these options in Lua config
vim.opt.shiftwidth = 2   -- Number of spaces for each indentation level
vim.opt.tabstop = 2      -- Number of spaces a tab represents
vim.opt.expandtab = true -- Convert tabs to spaces

vim.opt.smartindent = true -- Enable automatic indentation
vim.opt.autoindent = true -- Auto-indent new lines
-- Enable line break at word boundary
o.linebreak = true

-- Set the cursor type (e.g., block, vertical bar, underline)
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Set clipboard to use the system clipboard (only if supported)
o.clipboard = "unnamedplus" -- Allows use of system clipboard for copy-paste

-- Set background (dark or light)
o.background = "dark" -- or "light"

-- Ensure window options are modifiable before making changes
if bo.modifiable then
	-- Example buffer-specific options (only if the buffer is modifiable)
	bo.textwidth = 80 -- Example option
end
