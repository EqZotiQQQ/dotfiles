-- Часовой виджет
local wibox = require("wibox")

local clock = {}

function clock.create_clock()
    local clock = wibox.widget {
        format = "%H:%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }
    return clock
end

return clock
