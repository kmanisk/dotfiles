-- =============================================================================
--                             NVCHAD BASE OPTIONS
-- =============================================================================
require("nvchad.options")

local o = vim.o
local opt = vim.opt

-- =============================================================================
--                               GENERAL SETTINGS
-- =============================================================================
o.number         = true
o.relativenumber = true
o.smartcase      = true
o.ignorecase     = true
o.cursorline     = true
o.wrap           = true
o.linebreak      = true
o.termguicolors  = true
o.background     = "dark"
o.clipboard      = "unnamedplus"

-- =============================================================================
--                                INDENTATION
-- =============================================================================
o.shiftwidth     = 4
o.tabstop        = 4
o.softtabstop    = 4
o.smartindent    = true
o.autoindent     = true

-- =============================================================================
--                                   SEARCH
-- =============================================================================
opt.incsearch    = true
opt.inccommand   = "split"

-- =============================================================================
--                            PERFORMANCE & SESSION
-- =============================================================================
o.shada          = ""
opt.swapfile     = false
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- =============================================================================
--                              SHELL CONFIGURATION
-- =============================================================================
if vim.fn.executable("pwsh") == 1 then
    o.shell = "pwsh"
    o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;$PSStyle.OutputRendering = 'PlainText';"
else
    o.shell = "powershell"
    o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
end

o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
o.shellpipe  = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
o.shellquote = ""
o.shellxquote = ""

-- =============================================================================
--                               UI & APPEARANCE
-- =============================================================================
o.guicursor  = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
o.guifont    = "JetBrainsMono Nerd Font:h14"
o.linespace  = 9

-- =============================================================================
--                               NEOVIDE SPECIFIC
-- =============================================================================
if vim.g.neovide then
    vim.g.neovide_animation_fps = 100
    vim.g.neovide_scroll_animation_length = 0.3
    vim.g.neovide_cursor_animation_length = 0.05
    vim.g.neovide_cursor_trail_size = 0.5
end
