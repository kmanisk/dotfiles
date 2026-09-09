-- File: lua/configs/cmp.lua
local M = {}

M.setup = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    cmp.setup({
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),
            ["<M-i>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
        }, {
            { name = "buffer" },
            { name = "path" },
        }),
        window = {
            completion = {
                border = "single",
                winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                col_offset = -3,
                side_padding = 0,
            },
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }),
        },
    })
end

return M
