local d = require("dbg")

local cava_widget = require("widget.cava.cava")
local tray = require("configs.tray")
local cava = require("configs.cava")
local screen_widgets = {}

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
