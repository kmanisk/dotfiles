-- ==============================================================================
-- USER CONFIGURATION: default_apps.lua
-- ==============================================================================
-- Override default applications here.
-- These are Lua GLOBALS (defined WITHOUT the 'local' keyword) so that they
-- are accessible in every file require()d after this one in hyprland.lua.
--
-- This file is require()d at the very TOP of hyprland.lua — before all
-- other config files — so these variables are always in scope.
--
-- See: https://wiki.hypr.land/Configuring/Start/
-- ==============================================================================

-- -------------------------------------------------------------------------------------------------
-- User Configurable Defaults
-- -------------------------------------------------------------------------------------------------

terminal    = "alacritty"
fileManager = "thunar"
menu        = "/home/manisk/user_scripts/rofi/dusky_launcher.sh"
browser     = "brave"
textEditor  = "nvim"
