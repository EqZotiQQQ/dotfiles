local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local theme = require("themes.default.theme")
local client_bindings = require("widgets.taskbar.client_bindings")
local dbg = require("dbg")

local taglist_table = {}

function taglist_table.init_taskbar(screen, tasklist, layout_box, clock)
    local taskbar = awful.wibar({
        position = "left",
        screen = screen,
        width = 48,
        bg = theme.taskbar_config.color_bg,
        fg = theme.taskbar_config.color_fg,
    })

    taskbar:setup {
        layout = wibox.layout.align.vertical,
        {
            layout = wibox.layout.fixed.vertical,
            tasklist
        },
        clock,
        layout_box,
    }

    return taskbar
end

return taglist_table
