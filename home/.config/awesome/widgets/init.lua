--[[
     Widget module
--]]

local widgets = {
    cpu_widget = require("widgets.cpu-widget.cpu-widget"),
    volume_widget = require("widgets.volume-widget.volume"),
    cava = require("widgets.cava.cava"),
    textclock = require("widgets.textclock.textclock"),
}


-- local wibox = require("wibox")
-- widgets.textclock = {}
-- widgets.textclock.widget = wibox.widget.textclock("<span font=\"Iosevka 10\">%a\n%H:%M\n%d/%m</span>")
-- widgets.textclock.widget:set_align("center")

return widgets
