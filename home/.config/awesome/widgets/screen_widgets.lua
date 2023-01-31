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

local cava_widget = require("widgets.screen.cava.cava")
local panel_config = require("configs.panel")

local screen_widgets = {}

screen_widgets.init_cava = function(current_screen)
     return cava_widget(
        current_screen,
        {
            bars = panel_config.cava_config.bars,
            enable_interpolation = panel_config.cava_config.interpolation,
            size = panel_config.panel_size,
            position = panel_config.actual_position,
            update_time = panel_config.cava_config.update_time,
        }
    )
end

return screen_widgets
