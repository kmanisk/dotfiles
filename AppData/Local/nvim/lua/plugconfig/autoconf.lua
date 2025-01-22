

require("autosave").setup({
    enable = true,
    prompt = {
        enable = false, -- Disable the prompt
    },
    events = { "InsertLeave", "TextChanged" },
    conditions = {
        exists = true,
        modifiable = true,
        filename_is_not = {}, -- Add specific filenames to exclude if needed
        filetype_is_not = { "javascript", "typescriptreact", "json" }, -- Exclude js, tsx, and json filetypes
    },
    write_all_buffers = false,
    debounce_delay = 235,
})
