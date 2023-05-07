local dpi = require("beautiful").xresources.apply_dpi
local aligns = require("presets.aligns")
local panel_positions = require("presets.panel_position")

local panel_dpi = 50
local taglist_font_size = 13

local tray_config = {
    size = dpi(panel_dpi),
    position = panel_positions.top,
    align = aligns.center,
    taglist_font_size = taglist_font_size,
}

return tray_config