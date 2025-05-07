local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local theme = require("themes.default.theme")
local client_bindings = require("widgets.taglist.client_bindings")
local dbg = require("dbg")

local taglist_table = {}
function taglist_table.create_tag_list(screen)
    local taglist = awful.widget.taglist {
        screen          = screen,
        filter          = awful.widget.taglist.filter.all,
        align           = "center",
        valign          = "center",
        buttons         = client_bindings.tags_mouse_navigation,
        layout          = {
            spacing = 5,
            layout  = wibox.layout.fixed.vertical,
        },
        widget_template = {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            widget = wibox.container.background,
        },
    }
    return taglist
end

return taglist_table
