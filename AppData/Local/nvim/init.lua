-- =============================================================================
--                                LEADER KEYS
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =============================================================================
--                             VSCODE SPECIFIC SETUP
-- =============================================================================
if vim.g.vscode then
    local vscode_plugins = require("user.vsplug")
    require("lazy").setup(vscode_plugins)
    require("user.vscode_keymaps")
else
    -- =========================================================================
    --                             SHELL SETUP
    -- =========================================================================
    -- Load shell options early so all system calls use the correct shell
    require("shell")

    -- =========================================================================
    --                          LAZY.NVIM BOOTSTRAP
    -- =========================================================================
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.nvim.git"
        vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
    end
    vim.opt.rtp:prepend(lazypath)

    -- =========================================================================
    --                            NVCHAD SETTINGS
    -- =========================================================================
    vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"

    -- =========================================================================
    --                            PLUGIN SETUP
    -- =========================================================================
    require("lazy").setup({
        {
            "NvChad/NvChad",
            lazy = false,
            branch = "v2.5",
            import = "nvchad.plugins",
        },
        { import = "plugins" },
    }, require("configs.lazy"))

    -- =========================================================================
    --                             THEME LOADING
    -- =========================================================================
    pcall(dofile, vim.g.base46_cache .. "defaults")
    pcall(dofile, vim.g.base46_cache .. "statusline")

    -- =========================================================================
    --                             CORE MODULES
    -- =========================================================================
    require("options")

    -- =========================================================================
    --                            NEOVIDE SETTINGS
    -- =========================================================================
    if vim.g.neovide then
        vim.opt.guifont = "Iosevka Nerd Font Mono:h17"
    end

    -- =========================================================================
    --                              MAPPINGS
    -- =========================================================================
    vim.schedule(function()
        require("mappings")
    end)

    -- =========================================================================
    --                              AUTOCMDS
    -- =========================================================================
    require("nvchad.autocmds")

    -- Auto-source mappings on save
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*/lua/mappings.lua",
        callback = function()
            local mappings_path = vim.fn.stdpath("config") .. "/lua/mappings.lua"
            if vim.fn.filereadable(mappings_path) == 1 then
                vim.cmd("source " .. mappings_path)
            end
        end,
        desc = "Automatically source mappings.lua on save",
    })
end
