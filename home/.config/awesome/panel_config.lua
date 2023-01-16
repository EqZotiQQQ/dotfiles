local dpi = require("beautiful.xresources")

local panel_dpi = 50

local panel_orientation = {
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
    panel_size      = dpi.apply_dpi(panel_dpi),
    panel_position  = position.top,
}

return config