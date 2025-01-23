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
    {
        "NvChad/nvterm",
        enabled = false,
    },
    {
        "folke/which-key.nvim",
        enabled = false,
    },
    {
        "lewis6991/gitsigns.nvim",
        enabled = false,
    },

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
    {
        "wellle/targets.vim",
        cond = function()
            return not vim.g.vscode
        end,
    },
}
