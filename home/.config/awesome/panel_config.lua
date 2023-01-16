local dpi = require("beautiful").xresources.apply_dpi

local panel_dpi = 50

local cava_config = {
    update_time = 0.1,
    bars = 100,
    interpolation = false,
}

local orientation = {
    vertical = "vertical",
    horizontal = "horizontal"
}

local position = {
    top = "top",
    bottom = "bottom",
    left = "left",
    right = "right",
}

local align = {
    center = "center"
}

local config = {
    panel_orientation = orientation,
    panel_position = position,
    panel_size = dpi(panel_dpi),
    actual_position = position.top,
    align = align,
    cava_config = cava_config,
}

return config