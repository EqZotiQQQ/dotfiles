local dpi = require("beautiful").xresources.apply_dpi
local details = require("details")
local panel_dpi = 50
local taglist_font_size = 13

local cava_config = {
    update_time = 0.1,
    bars = 100,
    interpolation = false,
}


local align = {
    center = "center"
}

local config = {
    panel_size = dpi(panel_dpi),
    actual_position = details.position.top,
    align = align,
    cava_config = cava_config,
    taglist_font_size = taglist_font_size,
}

return config