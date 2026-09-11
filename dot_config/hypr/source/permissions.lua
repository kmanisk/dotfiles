-- -------------------------------------------------------------------------------------------------
-- SYSTEM PERMISSIONS ("HARDENED MODE")
-- -------------------------------------------------------------------------------------------------
-- By default, Hyprland allows apps to capture the screen via standard portals.
-- UNCOMMENT the block below ONLY if you want to lock down your system and
-- manually whitelist every app that needs screen access.
--

hl.config({
    -- ecosystem = {
    --   enforce_permissions = 1
    -- },

    -- --- Whitelist (Only active if ecosystem is enabled above) ---
    permission = {
        -- Allow standard screenshot tools
        [[/usr/(bin|local/bin)/grim, screencopy, allow]],
        [[/usr/(bin|local/bin)/slurp, screencopy, allow]],

        -- Allow the Portal (CRITICAL: This is what OBS uses)
        [[/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow]],

        -- Allow waybar (if you use wlr/workspaces or similar modules that need info)
        [[/usr/bin/waybar, screencopy, allow]],

        -- Hyprpm
        [[/usr/(bin|local/bin)/hyprpm, plugin, allow]]
    }
})
