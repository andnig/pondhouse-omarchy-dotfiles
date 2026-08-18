-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Pondhouse v3 Teams shortcut example (employee-owned and disabled).
-- Uncomment after choosing the employee-specific Teams launcher to run.
-- hl.unbind("SUPER + SHIFT + T")
-- o.bind("SUPER + SHIFT + T", "Teams", "gtk-launch teams-pondhouse")
-- End Pondhouse Teams shortcut example.

local workaround_module = "hypr.autostartworkaround"
local workaround = package.searchpath(workaround_module, package.path)
    and require(workaround_module)

hl.unbind("SUPER + CTRL + I")
hl.bind("SUPER + CTRL + I", function()
  if workaround and workaround.launch then
    workaround.launch()
  end
end, { description = "Open workspace apps" })

-- Pondhouse manual autostart workaround example (disabled).
-- Automatic workspace app launches can be unreliable in the current
-- Hyprland/UWSM setup. Add the applications you want to
-- ~/.config/hypr/autostartworkaround.lua, then uncomment this block to launch
-- them manually with SUPER+CTRL+I.
-- local workaround_module = "hypr.autostartworkaround"
-- local workaround = package.searchpath(workaround_module, package.path)
--     and require(workaround_module)
--
-- hl.unbind("SUPER + CTRL + I")
-- hl.bind("SUPER + CTRL + I", function()
--   if workaround and workaround.launch then
--     workaround.launch()
--   end
-- end, { description = "Open workspace apps" })
-- End Pondhouse manual autostart workaround example.
