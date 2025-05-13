local wibox = require("wibox")
local gears = require("gears")
local debug = require("dbg")

local net_widget = {}

function net_widget.new(screen)
    local widget_box = wibox({
        screen = screen,
        width = 150,
        height = 50,
        x = screen.geometry.width - 160,
        y = 20,
        ontop = true,
        visible = true,
        bg = "#00000080", -- полупрозрачный чёрный
        fg = "#FFFFFF",
        shape = gears.shape.rounded_rect
    })


    local content = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = 2,
        {
            id = "down",
            widget = wibox.widget.textbox,
            text = "↓ 0 KB/s"
        },
        {
            id = "up",
            widget = wibox.widget.textbox,
            text = "↑ 0 KB/s"
        }
    }

    local wrapped = debug.w(content)

    widget_box:setup {
        wrapped,
        margins = 10,
        layout = wibox.container.margin
    }

    return widget_box
end

return net_widget
