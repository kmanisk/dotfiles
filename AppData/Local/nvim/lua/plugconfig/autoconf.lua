local autosave = require("autosave")
autosave.hook_after_enable = function()
	print("Autosave plugin has been enabled.")
end
