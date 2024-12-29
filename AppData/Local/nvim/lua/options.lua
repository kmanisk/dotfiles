require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
--
-- Load default NvChad options first
require "nvchad.options"

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

-- Show line numbers, but relative line numbers are more helpful for movement
o.number = true
o.relativenumber = true

-- Enable search highlighting
o.hlsearch = true

-- Enable line wrapping for long lines
o.wrap = false  -- Set to false for no wrap, true for wrapping

-- Enable smart indentation (for auto indent)
o.smartindent = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true  -- Converts tabs to spaces
o.autoindent = true

-- Enable line break at word boundary
o.linebreak = true

-- Enable smart case search
o.smartcase = true

-- Set the cursor type (e.g., block, vertical bar, underline)
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Set the encoding for the file
o.fileencoding = "utf-8"

-- Set clipboard to use the system clipboard (only if supported)
o.clipboard = "unnamedplus"  -- Allows use of system clipboard for copy-paste

-- Set background (dark or light)
o.background = "dark"  -- or "light"

-- Enable line numbers
wo.number = true

-- Enable highlight search results
o.hlsearch = true
