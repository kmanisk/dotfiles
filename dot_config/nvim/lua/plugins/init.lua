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
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
        config = function()
            vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
            vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
            vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- customize popup window border
            vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim if available
            vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

            vim.g.lazygit_use_custom_config_file_path = 0 -- use default config path
            vim.g.lazygit_config_file_path = "" -- custom config file path
            -- OR
            vim.g.lazygit_config_file_path = {} -- table of custom config file paths

            vim.g.lazygit_on_exit_callback = nil -- optional function callback on exit
        end,
    },
}
