-- -- installing/Bootstrap lazy.nvim
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not (vim.uv or vim.loop).fs_stat(lazypath) then
-- 	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
-- 	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
-- 	if vim.v.shell_error ~= 0 then
-- 		vim.api.nvim_echo({
-- 			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
-- 			{ out, "WarningMsg" },
-- 			{ "\nPress any key to exit..." },
-- 		}, true, {})
-- 		vim.fn.getchar()
-- 		os.exit(1)
-- 	end
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- -- importing.
--
-- require("config.options")
-- require("config.globals")
-- require("config.keymaps")
-- require("config.autocmds")
--
-- -- Setup lazy.nvim
--
-- require("lazy").setup({
--
-- 	rocks = {
-- 		enabled = false,
-- 		hererocks = false,
-- 	},
--
-- 	spec = {
-- 		{ import = "plugins" },
-- 	},
-- 	rtp = {
-- 		disabled_plugins = {
-- 			"netrw",
-- 			"netrwPlugin",
-- 			"tohtml",
-- 			"tutor",
-- 			"zipPlugin", -- OPTIMIZATION: Disable zip plugin if not used
-- 		},
-- 	},
-- 	checker = {
-- 		enabled = true,
-- 		notify = false,
-- 	},
-- 	change_detection = {
-- 		notify = false, -- OPTIMIZATION: Less spam
-- 	},
-- })

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Load core configs
-- =========================
require("config.options")
require("config.globals")
require("config.keymaps")
require("config.autocmds")

-- =========================
-- Lazy.nvim setup
-- =========================
require("lazy").setup({
	rocks = {
		enabled = false,
		hererocks = false,
	},
	spec = {
		{ import = "plugins" },
	},
	rtp = {
		disabled_plugins = {
			"netrw",
			"netrwPlugin",
			"tohtml",
			"tutor",
			"zipPlugin",
		},
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})

-- =========================
-- Hot-reload config on save
-- =========================
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "init.lua", "lua/config/*.lua" }, -- watch main config and all lua modules
	callback = function()
		print("Reloading Neovim config...")

		-- clear cached modules for safe reload
		for name, _ in pairs(package.loaded) do
			if name:match("^config%.") then
				package.loaded[name] = nil
			end
		end

		-- re-require core configs
		require("config.options")
		require("config.globals")
		require("config.keymaps")
		require("config.autocmds")

		-- reload Lazy plugin specs
		vim.cmd("Lazy reload")
	end,
})
