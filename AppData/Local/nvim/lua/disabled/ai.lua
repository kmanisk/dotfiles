return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            debug = false,
            keymaps = {
                toggle = "<leader>cc",
            },
            -- Add more options as needed
        },
        config = function(_, opts)
            require("codecompanion").setup(opts)
        end,
    },
}
