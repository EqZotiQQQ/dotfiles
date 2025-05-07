local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local theme = require("themes.default.theme")
local bindings = require("widgets.layout_box.client_bindings")
local dbg = require("dbg")


local taglist_table = {}

function taglist_table.create_layout_box(screen)
    -- Layoutbox (смена лейаута)
    local layoutbox = awful.widget.layoutbox {
        screen = screen,
    }

    layoutbox:buttons(bindings.layout_control)
    return layoutbox
end

return taglist_table
