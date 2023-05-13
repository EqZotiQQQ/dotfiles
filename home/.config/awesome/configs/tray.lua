local dpi = require("beautiful").xresources.apply_dpi

local panel_dpi = 50
local taglist_font_size = 13

local tray_config = {
    size = dpi(panel_dpi),
    position = "top",
    align = "center",
    taglist_font_size = taglist_font_size,
}

return tray_config