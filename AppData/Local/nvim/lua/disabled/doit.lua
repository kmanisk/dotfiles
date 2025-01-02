
-- Define a table to hold all pluginse
print("loaded")
    -- Example: Disabling a default plugin
local plugins = {
{
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  opts = {},
  config = function(_, opts)
    vim.o.termguicolors = true
    vim.o.background = 'light'
    require('solarized').setup(opts)
    vim.cmd.colorscheme 'solarized'
  end,
}
}

-- Return the plugins table
return plugins
