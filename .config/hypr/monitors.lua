-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Pondhouse v3 monitor examples (disabled).
-- Replace output names with values from `hyprctl monitors all` before enabling.
-- hl.env("GDK_SCALE", "1")
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = tostring(omarchy_gdk_scale) })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = tostring(omarchy_gdk_scale), mirror = "DP-1" })
hl.monitor({ output = "sunshine", mode = "preferred", position = "auto", scale = tostring(omarchy_gdk_scale), mirror = "DP-1" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = tostring(omarchy_gdk_scale) })
-- End Pondhouse monitor examples.
