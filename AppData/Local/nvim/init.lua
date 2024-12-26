vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require("configs.lazy")

if vim.g.vscode then
  -- VSCode Neovim
  require("user.vscode_keymaps")
  --print("Loadded custom config")

else
  -- Ordinary Neovim setup
  require("lazy").setup({
    {
      "NvChad/NvChad",
      lazy = false,
      branch = "v2.5",
      import = "nvchad.plugins",
    },
    { import = "plugins" },
  }, lazy_config)

  -- load theme
  -- Define the missing highlight group if it's not already set
--vim.api.nvim_set_hl(0, 'IblChar', { fg = '#FF0000' })  -- Replace with your desired color

  dofile(vim.g.base46_cache .. "defaults")
  dofile(vim.g.base46_cache .. "statusline")
  require("options")
  require("custom.mappings")
  require("custom.init")
  require("nvchad.autocmds")

  vim.schedule(function()
    require("mappings")
  end)
end
