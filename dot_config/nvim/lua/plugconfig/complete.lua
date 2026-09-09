require("command-completion").setup({
	border = nil,
	max_col_num = 5,
	min_col_width = 20,
	use_matchfuzzy = true, -- Keep using matchfuzzy, but customize its logic
	highlight_selection = true,
	highlight_directories = true,
	tab_completion = true,

	-- Custom fuzzy matching function to enforce case-insensitivity
	custom_matchfuzzy = function(input, candidates)
		-- Convert both the input and candidates to lowercase for matching
		local lower_input = string.lower(input)
		local lower_candidates = {}

		-- Store both lowercase and original case candidates
		for _, candidate in ipairs(candidates) do
			table.insert(lower_candidates, { original = candidate, lower = string.lower(candidate) })
		end

		-- Perform fuzzy matching on the lowercase versions
		local matches = require("fuzzy").fuzzy_match(lower_input, lower_candidates)

		-- Ensure we preserve the original case in the final matches
		local result = {}
		for _, match in ipairs(matches) do
			table.insert(result, lower_candidates[match.index].original)
		end

		return result
	end,
})
