vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.java",
    callback = function()
        vim.cmd(":w")  -- Ensure the file is saved
        vim.cmd(":!javac % && java %<")  -- Compile and execute
    end,
})


-- Set a keybind to test functionality
vim.keymap.set("n", "<leader>ti", function()
    vim.cmd("!dir")
end, { desc = "Test Keybind" })

-- Automatically set filetype to 'vim' for unrecognized files
vim.cmd([[
  augroup SetFileTypeVim
    autocmd!
    autocmd BufNewFile,BufRead * set filetype=vim
  augroup END
]])
