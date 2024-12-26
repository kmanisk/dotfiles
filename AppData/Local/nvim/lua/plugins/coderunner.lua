return {
   {
      "akinsho/toggleterm.nvim",
      config = function()
         require("toggleterm").setup({
            size = 20,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_terminals = true,
            start_in_insert = true,
         })
      end,
   },
   {
      "CRAG666/code_runner.nvim",
      config = function()
         require("code_runner").setup({
            mode = "toggleterm",
            filetype = {
               python = "python3 -u",
               javascript = "node",
               lua = "lua",
               java = "cmd.exe /C javac $fileName && java $fileNameWithoutExt",  -- Adjusted for Windows
            },
            focus = true,
            startinsert = true,
         })
         
         -- Bind <leader>rf to run the file
         vim.api.nvim_set_keymap('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = true })
      end,
   },
}
