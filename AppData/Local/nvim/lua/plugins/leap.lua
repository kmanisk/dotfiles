-- plugins/leap.lua
return {
    'ggandor/leap.nvim',
  lazy = false,
    config = function()
        -- Set up leap.nvim with default mappings
        require('leap').add_default_mappings()

        -- Optional: Customize further settings
        require('leap').setup({
            highlight = {
                backdrop = 0.5,  -- Adjust backdrop opacity
                matches = "Search",  -- Highlight color for matches
            }
        })
    end
}
