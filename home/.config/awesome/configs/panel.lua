local dpi = require("beautiful").xresources.apply_dpi
local aligns = require("presets.aligns")
local panel_positions = require("presets.panel_position")

local panel_dpi = 50
local taglist_font_size = 13

local cava_config = {
    update_time = 1,
    bars = 100,
    interpolation = true,
    overlap_panel = false, -- due this option cava will overlap panel
}

local config = {
    panel_size = dpi(panel_dpi),
    actual_position = panel_positions.top,
    align = aligns.center,
    cava_config = cava_config,
    taglist_font_size = taglist_font_size,
}

return config