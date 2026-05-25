return {
    -- =========================================================================
    --                            CORE DEVELOPMENT
    -- =========================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.treesitter")
        end,
    },

    -- =========================================================================
    --                        LANGUAGE SERVER PROTOCOL (LSP)
    -- =========================================================================
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

    -- =========================================================================
    --                        CODE FORMATTING & LINTING
    -- =========================================================================
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

    -- =========================================================================
    --                             AUTO COMPLETION
    -- =========================================================================
    {
        "hrsh7th/nvim-cmp",
        cond = function()
            return not vim.g.vscode
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

    -- =========================================================================
    --                            UI & NAVIGATION
    -- =========================================================================
    {
        "nvim-tree/nvim-tree.lua",
        opts = function()
            return require("configs.nvim-tree")
        end,
        config = function(_, opts)
            require("nvim-tree").setup(opts)
        end,
    },

    {
        "Mofiqul/vscode.nvim",
        cond = function() return not vim.g.vscode end,
    },

    {
        "wellle/targets.vim",
        cond = function() return not vim.g.vscode end,
    },

    -- =========================================================================
    --                        EXTERNAL TOOL INTEGRATION
    -- =========================================================================
    {
        "CRAG666/code_runner.nvim",
        cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
        cond = function()
            return not vim.g.vscode
        end,
        config = function()
            require("configs.code_runner")
        end,
    },

    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
        config = function()
            vim.g.lazygit_floating_window_winblend = 0
            vim.g.lazygit_floating_window_scaling_factor = 0.9
            vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
            vim.g.lazygit_floating_window_use_plenary = 0
            vim.g.lazygit_use_neovim_remote = 1
        end,
    },

    {
        "akinsho/toggleterm.nvim",
        version = "*",
        lazy = false,
        config = function()
            require("configs.toggleterm")
        end,
    },

    -- =========================================================================
    --                           DISABLED DEFAULTS
    -- =========================================================================
    { "NvChad/nvterm", enabled = false },
    { "folke/which-key.nvim", enabled = false },
    { "lewis6991/gitsigns.nvim", enabled = false },
}
