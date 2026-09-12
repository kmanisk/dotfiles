-- ==============================================================================
-- USER CONFIGURATION: window_rules.lua
-- ==============================================================================
-- Add your custom window rules here.
-- These will override or add to the defaults found in ~/.config/hypr/source/
--
-- Syntax:
--   hl.window_rule({
--       name  = "my-rule-name",            -- unique identifier (required)
--       match = { class = "^kitty$" },     -- match table
--       float = true,
--   })
--
--   hl.layer_rule({
--       name  = "my-layer-rule",
--       match = { namespace = "^waybar$" },
--       blur  = true,
--   })
--
-- ==============================================================================
-- 1. TERMINAL WINDOWS (Kitty, Alacritty, Foot)
-- Slight opacity with subtle background blur, flat corners
-- ==============================================================================
hl.window_rule({
    name = "terminal-transparency",
    match = { class = "^(kitty|Alacritty|alacritty|foot)$" },
    opacity = "0.90 0.85",
    opaque = false,
    no_blur = false,
    rounding = 0,
})

-- ==============================================================================
-- 2. ALL BROWSERS & GUI APPS: 100% OPAQUE (NO BLUR, NO TRANSPARENCY, FLAT CORNERS)
-- ==============================================================================
hl.window_rule({
    name = "gui-apps-opaque",
    match = {
        class = "^(firefox.*|org\\.mozilla\\.firefox|chromium.*|Chromium.*|google-chrome.*|Google-chrome.*|brave.*|Brave.*|thunar|Thunar|mousepad|Mousepad|steam|Steam|vlc|mpv|pavucontrol|blueman-manager|zenity|org\\.gnome\\..*|TaskManagerOG)$"
    },
    opacity = "1.0 override 1.0 override",
    opaque = true,
    no_blur = true,
    rounding = 0,
})

-- ==============================================================================
-- 3. STEAM & GAMING RULES (Ported from X11 i3 Setup)
-- Dedicated Workspace 5 for Gaming
-- ==============================================================================
hl.window_rule({
    name = "steam-main-workspace",
    match = { class = "^(steam|Steam)$", title = "^Steam$" },
    workspace = "5",
    float = false,
    opaque = true,
    no_blur = true,
    rounding = 0,
})

hl.window_rule({
    name = "steam-dialogs-float",
    match = {
        class = "^(steam|Steam)$",
        title = "^(Friends List|.* - Chat|Settings|Steam - News.*|Screenshot Uploader|Steam Guard.*|Sign in to Steam)$"
    },
    float = true,
    opaque = true,
    no_blur = true,
    rounding = 0,
})

hl.window_rule({
    name = "games-workspace-gaming",
    match = { class = "^(cs2|gamescope|steam_app_.*|osu!)$" },
    workspace = "5",
    fullscreen = true,
    opaque = true,
    no_blur = true,
    no_shadow = true,
    no_anim = true,
    immediate = false, -- Stable baseline: no tearing until compositor is crash-free
    rounding = 0,
})

-- ==============================================================================
-- 4. UTILITY FLOATS (Calculator, pavucontrol, etc.)
-- ==============================================================================
hl.window_rule({
    name = "utility-floats",
    match = { class = "^(pavucontrol|blueman-manager|TaskManagerOG|imv|zenity|cachyos-welcome)$" },
    float = true,
    opaque = true,
    no_blur = true,
    rounding = 0,
})

-- ==============================================================================
-- 5. INSTANT ANIMATION-FREE SCRATCHPADS
-- ==============================================================================
hl.window_rule({
    name = "scratchpad-base",
    match = { class = "^(scratch-.*)$" },
    float = true,
    size = { "(monitor_w*0.95)", "(monitor_h*0.85)" },
    center = true,
    no_anim = true,
    opaque = true,
    rounding = 0,
})

hl.window_rule({
    name = "scratchpad-cmd-workspace",
    match = { class = "^(scratch-cmd)$" },
    workspace = "special:scratch-cmd",
})

hl.window_rule({
    name = "scratchpad-notes-workspace",
    match = { class = "^(scratch-notes)$" },
    workspace = "special:scratch-notes",
})

hl.window_rule({
    name = "scratchpad-monitor-workspace",
    match = { class = "^(scratch-monitor)$" },
    workspace = "special:scratch-monitor",
})

