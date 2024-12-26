require "nvchad.options"

-- add yours here!
vim.opt.relativenumber = true
-- Set clipboard to use the system clipboard

vim.opt.clipboard = ""
-- Automatically set filetype to vim for vifmrc file
vim.cmd([[
  augroup VifmrcFiletype
    autocmd!
    autocmd BufRead,BufNewFile $HOME/.vifm/vifmrc setlocal filetype=vim
  augroup END
]])


local M = {}

M.mappings = {
  -- Normal mode clipboard mappings
  n = {
    ["yy"] = { '"+yy', "Yank line to system clipboard" },
    ["gp"] = { '"+p', "Paste from system clipboard" },
    ["gP"] = { '"+P', "Paste before cursor from system clipboard" },
  },

  -- Visual mode clipboard mappings
  v = {
    ["y"] = { '"+y', "Yank to system clipboard" },
    ["<leader>y"] = { '"+y', "Yank to system clipboard (leader)" },
    ["p"] = { '"+p', "Paste from system clipboard" },
    ["J"] = { ":m .+1<CR>==", "Move line down" },
    ["K"] = { ":m .-2<CR>==", "Move line up" },
  },

  -- Visual block mode text movement
  x = {
    ["J"] = { ":move '>+1<CR>gv-gv", "Move block down" },
    ["K"] = { ":move '<-2<CR>gv-gv", "Move block up" },
  },
}

return M

