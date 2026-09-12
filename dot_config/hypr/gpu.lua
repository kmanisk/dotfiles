-- -----------------------------------------------------------------
-- Hyprland GPU | Mode: AUTO | Primary: /dev/dri/card1
-- GPU: Intel | Intel Corporation Raptor Lake-S UHD Graphics (rev 04) | 0000:00:02.0 | drv:i915
-- Gen: Python 3.14.6 + Rich + pyudev | systemd 261 | Hyprland 0.55.4+ Lua
-- DRM nodes shift per reboot - resolved via stable by-path
-- -----------------------------------------------------------------
local function resolve_card(pci_address, fallback)
 local cmd = "for d in /dev/dri/by-path/pci-"..pci_address.."*card; do [ -e \"$d\" ] && readlink -f \"$d\" 2>/dev/null && break; done"
 local h = io.popen(cmd)
 if h then
 local path = h:read("*l")
 h:close()
 if path and path ~= "" then return path end
 end
 return fallback
end

hl.env("AQ_DRM_DEVICES", resolve_card("0000:00:02.0", "/dev/dri/card1").. ":".. resolve_card("0000:01:00.0", "/dev/dri/card0"))

-- Intel
hl.env("LIBVA_DRIVER_NAME", "iHD")

-- Stability: disable explicit-fence passing on multi-GPU scanout.
-- Mitigates the Mesa 26.2 libgallium abort in dri_create_fence_fd /
-- CEGLSync::create seen in ~/.cache/hyprland crash reports on this
-- Intel iGPU + NVIDIA hybrid setup. No latency cost. Takes effect on
-- full Hyprland restart (logout/login), not on hyprctl reload.
hl.env("AQ_MGPU_NO_EXPLICIT", "1")
