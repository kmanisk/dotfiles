return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            version = "^1.0.0",
        },
    },
    config = function()
        local telescope = require("telescope")

        -- first setup telescope
        telescope.setup({
            defaults = {
                layout_config = {
                    -- Dynamic width based on terminal columns
                    width = function(_, cols, _)
                        if cols > 200 then
                            return 170  -- Set fixed width when cols > 200
                        else
                            return math.floor(cols * 0.87)  -- Set dynamic width based on screen size
                        end
                    end,
                    preview_cutoff = 120,
                },
            },
            pickers = {
                -- Adjusting layout for live_grep specifically
            --     live_grep = {
            --         layout_config = {
            --             preview_width = 0.75,  -- Increase preview width (75% of the screen)
            --             height = 0.9,          -- Height remains full screen (or adjust as needed)
            --             prompt_position = "bottom",  -- Position prompt at the bottom
            --             width = 0.8,           -- Set result width to 80% of screen
            --         },
            --     },
            -- },
            }
        })

        -- then load the extension
        telescope.load_extension("live_grep_args")
    end,
    cond = function()
        return not vim.g.vscode -- Exclude this plugin in VSCode
    end,
}
