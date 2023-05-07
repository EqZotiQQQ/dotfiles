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

local cava_widget = require("widgets.cava.cava")
local tray = require("configs.tray")
local cava = require("configs.cava")
local d = require("dbg")
local screen_widgets = {}

d.n("tray")

screen_widgets.init_cava = function(current_screen)
     return cava_widget(
        current_screen,
        {
            bars = cava.bars,
            enable_interpolation = cava.interpolation,
            size = tray.size,
            position = tray.position,
            update_time = cava.update_time,
        }
    )
end

return screen_widgets
