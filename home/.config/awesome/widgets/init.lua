--[[
     Widget module
--]]

-- local widgets = {
--     cpu_widget = require("widgets.cpu-widget.cpu-widget"),
--     volume_widget = require("widgets.volume-widget.volume"),
--     cava = require("widgets.cava.cava"),
--     textclock = require("widgets.textclock.textclock"),
--     calendar = require("widgets.calendar.calendar"),
--     network_widgets = require("widgets.network_widgets"),
-- }

-- return widgets

local volume_widget = require("widgets.panel.volume-widget.volume")
local clock_widget = require("widgets.panel.textclock.textclock")

local panel_widgets = {}

panel_widgets.textclock_widget = clock_widget{}

panel_widgets.volume_widget = volume_widget{
    widget_type = 'vertical_bar', -- [] arc | vertical_bar ]
    refresh_rate = 0.1
}

return panel_widgets