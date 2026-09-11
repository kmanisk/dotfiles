-- ==============================================================================
-- USER CONFIGURATION OVERLAY LOADER
-- ==============================================================================
-- This file is require()d at the bottom of hyprland.lua.
-- It loads all your custom configuration files from 'source/'.
-- Edit the specific files in 'source/' to apply your changes.
--
-- NOTE: 'default_apps.lua' is intentionally excluded here — it is require()d
-- directly at the top of hyprland.lua so its globals are available first.
-- ==============================================================================

require("edit_here.source.appearance")
require("edit_here.source.autostart")
require("edit_here.source.environment_variables")
require("edit_here.source.input")
require("edit_here.source.keybinds")
require("edit_here.source.monitors")
require("edit_here.source.plugins")
require("edit_here.source.trackpad")
require("edit_here.source.window_rules")
require("edit_here.source.workspace_rules")
