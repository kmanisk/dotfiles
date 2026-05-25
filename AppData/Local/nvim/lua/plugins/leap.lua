-- =============================================================================
--                                  LEAP.NVIM
-- =============================================================================
return {
    url = "https://codeberg.org/andyg/leap.nvim",
    lazy = false,
    -- Enable in VSCode as well, as requested
    config = function()
        -- =====================================================================
        --                             MAPPINGS
        -- =====================================================================
        -- Recommended replacement for add_default_mappings()
        vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
        vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
        vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')

        -- =====================================================================
        --                             CONFIGURATION
        -- =====================================================================
        require("leap").setup({
            highlight = {
                backdrop = 0.5,
                matches = "Search",
            },
        })
    end,
}
