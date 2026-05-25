return {
    "roobert/search-replace.nvim",
    cond = function()
        return not vim.g.vscode
    end,
    keys = {
        { "<leader>rs", "<CMD>SearchReplaceSingleBufferSelections<CR>", desc = "Search Replace Single Buffer Selections" },
        { "<leader>ro", "<CMD>SearchReplaceSingleBufferOpen<CR>", desc = "Search Replace Single Buffer Open" },
        { "<leader>rw", "<CMD>SearchReplaceSingleBufferCWord<CR>", desc = "Search Replace Single Buffer CWord" },
        { "<leader>rW", "<CMD>SearchReplaceSingleBufferCWORD<CR>", desc = "Search Replace Single Buffer CWORD" },
        { "<leader>re", "<CMD>SearchReplaceSingleBufferCExpr<CR>", desc = "Search Replace Single Buffer CExpr" },
        { "<leader>rf", "<CMD>SearchReplaceSingleBufferCFile<CR>", desc = "Search Replace Single Buffer CFile" },
        { "<leader>rbs", "<CMD>SearchReplaceMultiBufferSelections<CR>", desc = "Search Replace Multi Buffer Selections" },
        { "<leader>rbo", "<CMD>SearchReplaceMultiBufferOpen<CR>", desc = "Search Replace Multi Buffer Open" },
        { "<leader>rbw", "<CMD>SearchReplaceMultiBufferCWord<CR>", desc = "Search Replace Multi Buffer CWord" },
        { "<leader>rbW", "<CMD>SearchReplaceMultiBufferCWORD<CR>", desc = "Search Replace Multi Buffer CWORD" },
        { "<leader>rbe", "<CMD>SearchReplaceMultiBufferCExpr<CR>", desc = "Search Replace Multi Buffer CExpr" },
        { "<leader>rbf", "<CMD>SearchReplaceMultiBufferCFile<CR>", desc = "Search Replace Multi Buffer CFile" },
        { "<C-r>", "<CMD>SearchReplaceSingleBufferVisualSelection<CR>", mode = "v", desc = "Search Replace Single Buffer Visual Selection" },
        { "<C-s>", "<CMD>SearchReplaceWithinVisualSelection<CR>", mode = "v", desc = "Search Replace Within Visual Selection" },
        { "<C-b>", "<CMD>SearchReplaceWithinVisualSelectionCWord<CR>", mode = "v", desc = "Search Replace Within Visual Selection CWord" },
    },
    config = function()
        require("search-replace").setup({
            default_replace_single_buffer_options = "gcI",
            default_replace_multi_buffer_options = "egcI",
        })
        vim.o.inccommand = "split"
    end,
}
