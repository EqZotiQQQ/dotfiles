local volume_widget = require("widgets.panel.volume-widget.volume")
local clock_widget = require("widgets.panel.textclock.textclock")
local cpu_widget = require("widgets.panel.cpu-widget.cpu-widget")

local panel_widgets = {}

panel_widgets.init_textclock_widget = function()
    return clock_widget{}
end

panel_widgets.init_volume_widget = function()
    return volume_widget{
        widget_type = 'arc', -- [] arc | vertical_bar ]
        refresh_rate = 1
    }
end

panel_widgets.init_cpu_widget = function ()
    return cpu_widget{}
end

return panel_widgets