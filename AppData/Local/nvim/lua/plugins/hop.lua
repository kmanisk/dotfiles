
return{
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    keys = "etovxqpdygfblzhckisuran", -- Define the keys for hop
    -- Initialize the hop module and directions
  cond = function()
    return not vim.g.vscode -- Exclude this plugin in VSCode
  end,
}
}
