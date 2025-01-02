-- Load default NvChad options first
require("nvchad.options")

-- Basic settings
local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- Enable line numbers and relative line numbers
o.number = true
o.relativenumber = true
-- Function to check if a command exists
-- local function is_command_available(cmd)
--   return vim.fn.executable(cmd) == 1
-- end
--
-- -- Set the shell based on availability
-- if is_command_available("pwsh") then
--   vim.o.shell = "pwsh"
--   vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command $PSStyle.OutputRendering = 'PlainText';"
-- else
--   vim.o.shell = "powershell"
--   vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
-- end
--
-- -- Common shell settings
-- vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
-- vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
-- vim.o.shellquote = ""
-- vim.o.shellxquote = ""
-- -- Common shell settings
-- vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
-- vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
-- vim.o.shellquote = ""
-- vim.o.shellxquote = ""
vim.opt.swapfile = false

-- Set shell to pwsh or fallback to powershell
if vim.fn.executable("pwsh") == 1 then
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command $PSStyle.OutputRendering = 'PlainText';"
else
    vim.o.shell = "powershell"
    vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
end

-- Configure shell output redirection
vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.o.shellquote = ""
vim.o.shellxquote = ""
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
