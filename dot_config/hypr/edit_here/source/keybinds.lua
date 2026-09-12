-- ==============================================================================
-- USER CONFIGURATION: keybinds.lua
-- ==============================================================================
-- Add your custom keybinds here.
-- These override and cleanly unbind the defaults found in ~/.config/hypr/source/
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 0. UNBIND DEFAULTS (Eliminate duplicates & conflicting actions)
-- ------------------------------------------------------------------------------
local unbinds = {
    -- Window & Session Controls
    "SUPER + Q",
    "SUPER + C",
    "SUPER + E",
    "SUPER + M",
    "SUPER + F",
    "SUPER + A",
    "SUPER + semicolon",
    "SUPER + Z",
    "SUPER + SHIFT + Z",
    "SUPER + TAB",
    "SUPER + comma",
    "SUPER + period",
    "SUPER + slash",
    "SUPER + SHIFT + comma",
    "SUPER + SHIFT + period",
    "SUPER + SHIFT + slash",
    "SUPER + SHIFT + SPACE",
    "ALT + SPACE",
    "ALT + SHIFT + SPACE",
    "CTRL + SPACE",
    "CTRL + SHIFT + escape",
    "SUPER + CTRL + L",
    "SUPER + escape",
    "ALT + escape",
    "SUPER + RETURN",
    "ALT + RETURN",
    "ALT + V", -- Remove Dusky QuickPanel shortcut
    "SUPER + SHIFT + apostrophe", -- Unbind default wallpaper cycling shortcut

    -- App shortcuts
    "SUPER + B",
    "SUPER + SHIFT + B",
    "SUPER + ALT + B",
    "SUPER + SHIFT + T",
    "SUPER + SHIFT + G",

    -- Workspace navigation keys (u, i, o, p)
    "SUPER + U",
    "SUPER + I",
    "SUPER + O",
    "SUPER + P",
    "SUPER + SHIFT + U",
    "SUPER + SHIFT + I",
    "SUPER + SHIFT + O",
    "SUPER + SHIFT + P",

    -- Directional navigation keys (h, j, k, l)
    "SUPER + H",
    "SUPER + J",
    "SUPER + K",
    "SUPER + L",
    "SUPER + SHIFT + H",
    "SUPER + SHIFT + J",
    "SUPER + SHIFT + K",
    "SUPER + SHIFT + L",
}

for _, key in ipairs(unbinds) do
    hl.unbind(key)
end

-- Unbind all workspace / context number keys (0-9)
for i = 0, 9 do
    local n = tostring(i)
    hl.unbind("SUPER + " .. n)
    hl.unbind("SUPER + SHIFT + " .. n)
    hl.unbind("SUPER + CTRL + " .. n)
    hl.unbind("SUPER + ALT + " .. n)
end

-- ==============================================================================
-- 1. WORKSPACE MANAGEMENT (PORTED FROM X11 I3 dots)
-- ==============================================================================

-- Top-Row Right-Hand Workspace Switching (Windows + u i o p)
hl.bind("SUPER + U", hl.dsp.focus({ workspace = "1" }), { description = "Switch To Workspace 1" })
hl.bind("SUPER + I", hl.dsp.focus({ workspace = "2" }), { description = "Switch To Workspace 2" })
hl.bind("SUPER + O", hl.dsp.focus({ workspace = "3" }), { description = "Switch To Workspace 3" })
hl.bind("SUPER + P", hl.dsp.focus({ workspace = "4" }), { description = "Switch To Workspace 4" })

-- Top-Row Right-Hand Move Window (Windows + Shift + u i o p)
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "1" }), { description = "Move Window To Workspace 1" })
hl.bind("SUPER + SHIFT + I", hl.dsp.window.move({ workspace = "2" }), { description = "Move Window To Workspace 2" })
hl.bind("SUPER + SHIFT + O", hl.dsp.window.move({ workspace = "3" }), { description = "Move Window To Workspace 3" })
hl.bind("SUPER + SHIFT + P", hl.dsp.window.move({ workspace = "4" }), { description = "Move Window To Workspace 4" })

-- Standard Number Workspace Switching (Windows + 1..0)
for i = 1, 9 do
    local n = tostring(i)
    hl.bind("SUPER + " .. n, hl.dsp.focus({ workspace = n }), { description = "Switch To Workspace " .. n })
    -- Move Window to Workspace and Follow Focus (Windows + Ctrl + 1..9)
    hl.bind("SUPER + CTRL + " .. n, hl.dsp.window.move({ workspace = n }), { description = "Move Window To Workspace " .. n })
    -- Move Window Silently to Workspace (Windows + Alt + 1..9)
    hl.bind("SUPER + ALT + " .. n, hl.dsp.window.move({ workspace = n, follow = false }), { description = "Silent Move Window To Workspace " .. n })
end

-- Workspace 10 (Windows + 0)
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }), { description = "Switch To Workspace 10" })
hl.bind("SUPER + CTRL + 0", hl.dsp.window.move({ workspace = "10" }), { description = "Move Window To Workspace 10" })
hl.bind("SUPER + ALT + 0", hl.dsp.window.move({ workspace = "10", follow = false }), { description = "Silent Move Window To Workspace 10" })

-- Windows + Shift + 4..0 to move to workspace (workspaces 1..3 reserved for nmtui/blueman/pavucontrol)
for i = 4, 9 do
    local n = tostring(i)
    hl.bind("SUPER + SHIFT + " .. n, hl.dsp.window.move({ workspace = n }), { description = "Move Window To Workspace " .. n })
end
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }), { description = "Move Window To Workspace 10" })

-- Sequential Workspace Navigation (Windows + , and . [< and >])
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })
hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind("SUPER + SHIFT + comma", hl.dsp.window.move({ workspace = "e-1" }), { description = "Move Window to Prev Workspace & Follow" })
hl.bind("SUPER + SHIFT + period", hl.dsp.window.move({ workspace = "e+1" }), { description = "Move Window to Next Workspace & Follow" })

-- Back and Forth with last workspace (Windows + Tab)
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "previous" }), { description = "Toggle Last Workspace" })

-- Scratchpads (Ergonomic Lazy-loaded, Zero-Animation)
hl.bind("CTRL + SPACE", hl.dsp.workspace.toggle_special("scratch-cmd"), { description = "Toggle Scratchpad Terminal (Ctrl + Space)" })
-- Removed SUPER + apostrophe (reserved for Wallpaper cycle) and SUPER + C per user preference
hl.bind("SUPER + N", hl.dsp.workspace.toggle_special("scratch-notes"), { description = "Toggle Scratchpad Notes" })
hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("scratch-monitor"), { description = "Toggle Scratchpad System Monitor" })
hl.bind("SUPER + B", hl.dsp.workspace.toggle_special("scratch-monitor"), { description = "Toggle Scratchpad System Monitor (Btop)" })
hl.bind("SUPER + Z", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle Generic Scratchpad" })
hl.bind("SUPER + SHIFT + Z", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move Window to Scratchpad" })

-- Gaming Shortcut: switch to Workspace 5 and launch Steam
hl.bind("ALT + SHIFT + S", function()
    hl.dispatch(hl.dsp.focus({ workspace = "5" }))
    hl.dispatch(hl.dsp.exec_cmd("dusky-run steam"))
end, { description = "Gaming: Workspace 5 + Launch Steam" })

-- ==============================================================================
-- 2. WINDOW MANAGEMENT & FOCUS NAVIGATION (Windows + hjkl & Controls)
-- ==============================================================================
-- Kill / Close Window (Windows + q)
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Kill / Close Focused Window" })

-- Fullscreen & Floating Toggles
hl.bind("SUPER + F", hl.dsp.window.fullscreen(), { description = "Toggle Fullscreen" })
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float(), { description = "Toggle Floating" })

-- Focus Movement (Windows + hjkl)
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "Focus Left" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }), { description = "Focus Down" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }), { description = "Focus Up" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }), { description = "Focus Right" })

-- Window Movement (Windows + Shift + hjkl)
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }), { description = "Move Window Left" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Move Window Down" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Move Window Up" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }), { description = "Move Window Right" })

-- Split Layout Toggle (Windows + semicolon & Windows + a)
hl.bind("SUPER + semicolon", hl.dsp.layout("togglesplit"), { description = "Toggle Split Direction" })
hl.bind("SUPER + A", hl.dsp.layout("togglesplit"), { description = "Toggle Split Direction" })

-- ==============================================================================
-- 3. APPLICATION LAUNCHERS & UTILITIES (PORTED FROM I3 DOTS)
-- ==============================================================================
-- Terminal (Alt + Return & Windows + Return)
hl.bind("ALT + RETURN", hl.dsp.exec_cmd("dusky-run " .. terminal), { description = "Launch Terminal" })
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("dusky-run " .. terminal), { description = "Launch Terminal" })

-- App Launcher (Alt + Space)
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("pkill rofi; /home/manisk/user_scripts/rofi/dusky_launcher.sh"), { description = "Dusky Application Launcher", submap_universal = true })

-- Browsers (Windows + Shift + b -> Intel iGPU / Default, Windows + Alt + b -> NVIDIA RTX 5050)
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("dusky-run brave-origin"), { description = "Brave Browser (iGPU)" })
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("dusky-run brave-nvidia"), { description = "Brave Browser (NVIDIA Vulkan)" })

-- File Manager
hl.bind("SUPER + E", hl.dsp.exec_cmd("dusky-run " .. fileManager), { description = "File Manager" })

-- Calculator (Windows + Alt + c to avoid clash with Force-Kill)
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("dusky-run gnome-calculator"), { description = "Calculator" })

-- Text Editor (Windows + Shift + t -> Neovim in terminal)
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("dusky-run " .. terminal .. " -e nvim"), { description = "Neovim" })

-- System Utilities (Windows + Shift + 1/2/3)
hl.bind("SUPER + SHIFT + 1", hl.dsp.exec_cmd("dusky-run " .. terminal .. " --class nmtui -e nmtui"), { description = "Network Manager (nmtui)" })
hl.bind("SUPER + SHIFT + 2", hl.dsp.exec_cmd("dusky-run blueman-manager"), { description = "Bluetooth Manager" })
hl.bind("SUPER + SHIFT + 3", hl.dsp.exec_cmd("dusky-run pavucontrol"), { description = "Audio Control (pavucontrol)" })
-- Audio Output Device Switcher (Windows + Ctrl + o)
hl.bind("SUPER + CTRL + O", hl.dsp.exec_cmd("/home/manisk/.local/bin/toggle-audio-sink"), { description = "Toggle Audio Output Device" })

-- Task Manager (Ctrl + Shift + Escape)
hl.bind("CTRL + SHIFT + escape", hl.dsp.exec_cmd("dusky-run " .. terminal .. " --class btop -e btop"), { description = "Task Manager (btop)" })

-- Screen Lock (Windows + Ctrl + l)
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock Screen" })

-- Powermenu (Windows + Escape / Alt + Escape)
hl.bind("SUPER + escape", hl.dsp.exec_cmd("pkill rofi; rofi -show power-menu -modi power-menu:/home/manisk/user_scripts/rofi/powermenu.sh"), { description = "Power Menu" })
hl.bind("ALT + escape", hl.dsp.exec_cmd("pkill rofi; rofi -show power-menu -modi power-menu:/home/manisk/user_scripts/rofi/powermenu.sh"), { description = "Power Menu" })

-- Night Light (hyprsunset)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("/home/manisk/.local/bin/hypr-nightlight toggle"), { description = "Toggle Night Light" })
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.exec_cmd("/home/manisk/.local/bin/hypr-nightlight adjust -300"), { description = "Increase Night Light Warmth (Warmer / More Yellow)" })
hl.bind("SUPER + SHIFT + apostrophe", hl.dsp.exec_cmd("/home/manisk/.local/bin/hypr-nightlight adjust +300"), { description = "Reduce Night Light (Cooler / Less Yellow)" })
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.exec_cmd("/home/manisk/.local/bin/hypr-nightlight adjust +300"), { description = "Reduce Night Light (Cooler / Less Yellow)" })

-- Clipboard Manager (Alt + V)
hl.bind("ALT + V", hl.dsp.exec_cmd("pkill rofi; rofi -modi \"clipboard:" .. dusky_scripts .. "rofi/rofi_clipboard.sh\" -show clipboard"), { description = "Clipboard Manager (Rofi)" })


-- Unbind removed Waybar shortcut
hl.unbind("ALT + 9")


