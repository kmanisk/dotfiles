-- local ensure_installed = {
--     -- Language servers
--     "typescript-language-server", -- TypeScript/JavaScript LSP
--     -- "json-lsp", -- JSON LSP
--     -- "lua-language-server",        -- Lua LSP
--
--     -- Linters/Formatters
--     "eslint_d",  -- ESLint
--     "prettierd", -- Prettier
-- }
-- -- comment this to make the lua lsp work
-- vim.g.disable_lua_lsp = true
-- -- Conditionally include Lua LSP
-- if not vim.g.disable_lua_lsp then
--     table.insert(ensure_installed, "lua-language-server")
-- end
return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.treesitter")
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require("configs.lspconfig")
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.lint")
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("configs.conform")
        end,
    },

    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        cond = function()
            return not vim.g.vscode -- Exclude this plugin in VSCode
        end,
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind-nvim",
            "kyazdani42/nvim-web-devicons",
        },
        config = function()
            require("configs.cmp").setup()
        end,
    },

    --     {
    --         "williamboman/mason.nvim",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         opts = {
    --             ensure_installed = ensure_installed,
    --         },
    --         config = function()
    --             require("mason").setup()
    --         end,
    --     },
    --
    --     -- Mason LSP Configuration
    --     {
    --         "williamboman/mason-lspconfig.nvim",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             -- Extract only LSP servers from `ensure_installed`
    --             local lsp_servers = vim.tbl_filter(function(tool)
    --                 return tool:find("-language-server") or tool:match("lsp")
    --             end, ensure_installed)
    --
    --             require("mason-lspconfig").setup({
    --                 ensure_installed = lsp_servers,
    --             })
    --         end,
    --     },
    --
    --     -- LSP Config
    --     {
    --         "neovim/nvim-lspconfig",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             local lspconfig = require("lspconfig")
    --             local mason_lspconfig = require("mason-lspconfig")
    --             local capabilities = require("cmp_nvim_lsp").default_capabilities()
    --
    --             -- Default `on_attach` function
    --             local on_attach = function(client, bufnr)
    --                 local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --                 vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    --                 vim.keymap.set("n", "L", vim.lsp.buf.hover, bufopts)
    --                 vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    --                 vim.keymap.set("n", "<Leader>rn", function()
    --                     require("nvchad.lsp.renamer")()
    --                 end, bufopts)
    --                 vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    --                 vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
    --                 vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
    --             end
    --
    --             mason_lspconfig.setup_handlers({
    --                 function(server_name)
    --                     if server_name == "lua_ls" and vim.g.disable_lua_lsp then
    --                         return -- Skip Lua LSP setup if disabled
    --                     end
    --                     lspconfig[server_name].setup({
    --                         on_attach = on_attach,
    --                         capabilities = capabilities,
    --                     })
    --                 end,
    --             })
    --
    --             -- Additional Lua-specific configuration
    --             if not vim.g.disable_lua_lsp then
    --                 lspconfig.lua_ls.setup({
    --                     on_attach = on_attach,
    --                     capabilities = capabilities,
    --                     settings = {
    --                         Lua = {
    --                             runtime = { version = "LuaJIT" },
    --                             diagnostics = { globals = { "vim" } },
    --                             workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    --                             telemetry = { enable = false },
    --                         },
    --                     },
    --                 })
    --             end
    --         end,
    --     },
    --
    --     -- Treesitter for Syntax Highlighting
    --     {
    --         "nvim-treesitter/nvim-treesitter",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         opts = {
    --             ensure_installed = { "typescript", "javascript", "json", "powershell", "lua" },
    --             highlight = { enable = true },
    --             indent = { enable = true },
    --         },
    --     },
    --
    --     -- Autocompletion
    --     {
    --         "hrsh7th/nvim-cmp",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         dependencies = {
    --             "hrsh7th/cmp-nvim-lsp",
    --             "hrsh7th/cmp-buffer",
    --             "hrsh7th/cmp-path",
    --             "L3MON4D3/LuaSnip",
    --             "saadparwaiz1/cmp_luasnip",
    --             "onsails/lspkind-nvim",
    --             "kyazdani42/nvim-web-devicons",
    --         },
    --         config = function()
    --             local cmp = require("cmp")
    --             local lspkind = require("lspkind")
    --
    --             cmp.setup({
    --                 snippet = {
    --                     expand = function(args)
    --                         require("luasnip").lsp_expand(args.body)
    --                     end,
    --                 },
    --                 mapping = cmp.mapping.preset.insert({
    --                     ["<Tab>"] = cmp.mapping.select_next_item(),
    --                     ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    --                     ["<CR>"] = cmp.mapping.confirm({ select = true }),
    --                     ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    --                     ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    --                     ["<C-d>"] = cmp.mapping.scroll_docs(4),
    --                     ["<M-i>"] = cmp.mapping.complete(),
    --                 }),
    --                 sources = cmp.config.sources({
    --                     { name = "nvim_lsp" },
    --                     { name = "luasnip" },
    --                 }, {
    --                     { name = "buffer" },
    --                 }),
    --                 window = {
    --                     completion = {
    --                         border = "single",
    --                         winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    --                         col_offset = -3,
    --                         side_padding = 0,
    --                     },
    --                 },
    --                 formatting = {
    --                     fields = { "kind", "abbr", "menu" },
    --                     format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }),
    --                 },
    --             }
    --             )
    --         end,
    --     },
    --
    --     -- Formatter and Linter Integration
    --     {
    --         "jose-elias-alvarez/null-ls.nvim",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             local null_ls = require("null-ls")
    --             null_ls.setup({
    --                 sources = {
    --                     null_ls.builtins.formatting.prettierd,
    --                     null_ls.builtins.diagnostics.eslint_d,
    --                     null_ls.builtins.code_actions.eslint_d,
    --                 },
    --                 on_attach = function(client, bufnr)
    --                     if client.supports_method("textDocument/formatting") then
    --                         vim.api.nvim_buf_set_keymap(
    --                             bufnr,
    --                             "n",
    --                             "<Leader>fc",
    --                             "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
    --                             { noremap = true, silent = true }
    --                         )
    --                     end
    --                 end,
    --             })
    --         end,
    --     },
    --     --   only diables statusline
    --     {
    --         "nvchad/ui",
    --         lazy = false,
    --         config = function()
    --             -- if commneted remove tab bar and statusline too both of them
    --             require("nvchad")
    --             -- the below only diables statusline
    --             -- vim.opt.statusline = ""
    --         end,
    --     },
    --     {
    --         "NvChad/nvterm",
    --         enabled = false,
    --     },
    --     {
    --         "folke/which-key.nvim",
    --         enabled = false,
    --     },
    --     {
    --         "lewis6991/gitsigns.nvim",
    --         enabled = false,
    --     },
    --     {
    --         "stevearc/conform.nvim",
    --         -- enabled = false,
    --         event = "BufWritePre", -- uncomment for format on save
    --         opts = require("configs.conform"),
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --     },
    --  {
    --     "xiyaowong/transparent.nvim",
    --     config = function()
    --         require("transparent").setup({
    --             groups = {
    --                 'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    --                 'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    --                 'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    --                 'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
    --                 'EndOfBuffer',
    --             },
    --             extra_groups = {}, -- Add any additional groups to clear here
    --             exclude_groups = {}, -- Add any groups you want to exclude here
    --             on_clear = function()
    --                 -- Optional: Add custom actions to execute after clearing
    --             end,
    --         })
    --     end,
    -- },
    -- {
    -- 	"smoka7/hop.nvim",
    -- 	version = "*",
    -- 	opts = {
    -- 		keys = "etovxqpdygfblzhckisuran", -- Define the keys for hop
    -- 		-- Initialize the hop module and directions
    -- 		cond = function()
    -- 			return not vim.g.vscode -- Exclude this plugin in VSCode
    -- 		end,
    -- 	},
    -- },

    {
        "CRAG666/code_runner.nvim",
        config = true,
        cond = function()
            return not vim.g.vscode -- Exclude this plugin in VSCode
        end,
    },

    {
        "Mofiqul/vscode.nvim",
        cond = function()
            return not vim.g.vscode -- Exclude this plugin in VSCode
        end,
    },
    { "wellle/targets.vim" },

    --
    --         {
    --             "williamboman/mason.nvim",
    --             cond = function()
    --                 return not vim.g.vscode -- Exclude this plugin in VSCode
    --             end,
    --             opts = {
    --                 ensure_installed = {
    --                     "typescript-language-server", -- TypeScript/JavaScript LSP
    --                     "eslint_d", -- ESLint
    --                     "prettierd", -- Prettier
    --                     "json-lsp" -- JSON LSP
    --
    --                     -- "lua-language-server", -- Lua (optional for Neovim config)
    --                 },
    --             },
    --             config = function()
    --                 require("mason").setup()
    --             end,
    --         },
    --
    --     -- Mason LSP Configuration
    --     {
    --         "williamboman/mason-lspconfig.nvim",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             require("mason-lspconfig").setup({
    --                 ensure_installed = {
    --                     "ts_ls", -- TypeScript LSP
    --                     "jsonls", -- JSON LSP
    --                 },
    --             })
    --         end,
    --     },
    --
    --     -- LSP Config
    --     {
    --         "neovim/nvim-lspconfig",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             local lspconfig = require("lspconfig")
    --             local mason_lspconfig = require("mason-lspconfig")
    --             local capabilities = require("cmp_nvim_lsp").default_capabilities()
    --
    --             -- Default `on_attach` function
    --             local on_attach = function(client, bufnr)
    --                 local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --                 vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    --                 vim.keymap.set("n", "L", vim.lsp.buf.hover, bufopts)
    --                 vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    --                 -- vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
    --                 vim.keymap.set("n", "<Leader>rn", function()
    --                   require("nvchad.lsp.renamer")()  -- Call the NVChad renamer function
    --                 end, opts)
    --                 vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    --                 vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
    --                 vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
    --             end
    --
    --             mason_lspconfig.setup_handlers({
    --                 function(server_name)
    --                     lspconfig[server_name].setup({
    --                         on_attach = on_attach,
    --                         capabilities = capabilities,
    --                     })
    --                 end,
    --             })
    --
    --             -- Additional LSP configurations (e.g., tsserver)
    --             lspconfig.ts_ls.setup({
    --                 on_attach = on_attach,
    --                 capabilities = capabilities,
    --                 settings = {
    --                     typescript = {
    --                         format = { enable = true }, -- Disable formatting if using Prettier
    --                     },
    --                     javascript = {
    --                         format = { enable = false }, -- Disable formatting if using Prettier
    --                     },
    --                 },
    --             })
    --         end,
    --     },
    --
    --     -- Treesitter for Syntax Highlighting
    --     {
    --         "nvim-treesitter/nvim-treesitter",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         opts = {
    --             ensure_installed = { "typescript", "javascript", "json","powershell", "lua" },
    --             highlight = { enable = true },
    --             indent = { enable = true },
    --         },
    --     },
    --
    --     -- Autocompletion
    --
    -- {
    --   "hrsh7th/nvim-cmp",
    -- opts = {
    --       sources = {
    --         name = "codeium",
    --       },
    --     },
    --   cond = function()
    --       return not vim.g.vscode -- Exclude this plugin in VSCode
    --   end,
    --   dependencies = {
    --       "hrsh7th/cmp-nvim-lsp",
    --       "hrsh7th/cmp-buffer",
    --       "hrsh7th/cmp-path",
    --       "L3MON4D3/LuaSnip",
    --       "saadparwaiz1/cmp_luasnip",
    --       "onsails/lspkind-nvim", -- For VS Code-like icons
    --       "kyazdani42/nvim-web-devicons", -- For file icons
    --   },
    --   config = function()
    --       local cmp = require("cmp")
    --       local lspkind = require("lspkind")
    --
    --       cmp.setup({
    --           snippet = {
    --               expand = function(args)
    --                   require("luasnip").lsp_expand(args.body)
    --               end,
    --           },
    --           mapping = cmp.mapping.preset.insert({
    --               ["<Tab>"] = cmp.mapping.select_next_item(),
    --               ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    --               ["<CR>"] = cmp.mapping.confirm({ select = true }),
    --                 ["<C-y>"] = cmp.mapping.confirm({ select = true }),    -- Confirm selection (Ctrl + y)
    --                 ["<C-u>"] = cmp.mapping.scroll_docs(-4),               -- Scroll up in documentation
    --                 ["<C-d>"] = cmp.mapping.scroll_docs(4),                -- Scroll down in documentation
    --                 ["<M-i>"] = cmp.mapping.complete(),                    -- Show completion menu (Alt + i)
    --           }),
    --           sources = cmp.config.sources({
    --               { name = "nvim_lsp" },
    --               { name = "luasnip" },
    --           }, {
    --               { name = "buffer" },
    --           }),
    --          window = {
    --             completion = {
    --                         border='single',
    --               winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    --               col_offset = -3,
    --               side_padding = 0,
    --             },
    --           },
    --           formatting = {
    --             fields = { "kind", "abbr", "menu" },
    --             format = function(entry, vim_item)
    --               local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
    --               local strings = vim.split(kind.kind, "%s", { trimempty = true })
    --               kind.kind = " " .. (strings[1] or "") .. " "
    --               kind.menu = "    (" .. (strings[2] or "") .. ")"
    --               return kind
    --
    --             end,
    --           },
    --           -- formatting = {
    --           --     format = lspkind.cmp_format({
    --           --         with_text = true,
    --           --         maxwidth = 50,
    --           --         ellipsis_char = "...",
    --           --     }),
    --           -- },
    --           -- window = {
    --           --     completion = {
    --           --         border = "rounded",
    --           --         winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    --           --         col_offset = -3,
    --           --         side_padding = 0,
    --           --     },
    --           --     documentation = {
    --           --         border = "rounded",
    --           --         winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    --           --     },
    --           -- },
    --       })
    --   end,
    -- },
    --
    --     -- Formatter and Linter Integration
    --     {
    --         "jose-elias-alvarez/null-ls.nvim",
    --         cond = function()
    --             return not vim.g.vscode -- Exclude this plugin in VSCode
    --         end,
    --         config = function()
    --             local null_ls = require("null-ls")
    --             null_ls.setup({
    --                 sources = {
    --                     null_ls.builtins.formatting.prettierd,
    --                     null_ls.builtins.diagnostics.eslint_d,
    --                     null_ls.builtins.code_actions.eslint_d,
    --                 },
    --                 on_attach = function(client, bufnr)
    --                     if client.supports_method("textDocument/formatting") then
    --                         vim.api.nvim_buf_set_keymap(
    --                             bufnr,
    --                             "n",
    --                             "<Leader>fc",
    --                             "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
    --                             { noremap = true, silent = true }
    --                         )
    --                     end
    --                 end,
    --             })
    --         end,
    --     },
}
