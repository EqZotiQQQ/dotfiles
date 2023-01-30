local volume_widget = require("widgets.panel.volume-widget.volume")
local clock_widget = require("widgets.panel.textclock.textclock")

local panel_widgets = {}

panel_widgets.init_textclock_widget = function()
    return clock_widget{}
end

panel_widgets.init_volume_widget = function()
    return volume_widget{
        widget_type = 'vertical_bar', -- [] arc | vertical_bar ]
        refresh_rate = 0.1
    }
end

return panel_widgets