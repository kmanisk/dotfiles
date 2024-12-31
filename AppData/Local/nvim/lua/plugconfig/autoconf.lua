require("autosave").setup({
	enable = true,
	prompt = {
		enable = false, -- Disable the prompt
	},
	events = { "InsertLeave", "TextChanged" },
	conditions = {
		exists = true,
		modifiable = true,
		filename_is_not = {},
		filetype_is_not = {},
	},
	write_all_buffers = false,
	debounce_delay = 235,
})
