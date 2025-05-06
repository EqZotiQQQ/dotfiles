local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local theme = require("themes.default.theme")
local mouse_bindings = require("widgets.mouse_bindings")

local taglist_table = {}

function taglist_table.full_init_taskbar(screen)
    local tasklist = taglist_table.create_tag_list(screen)
    local layout_box = taglist_table.create_layout_box(screen)
    screen.taskbar = taglist_table.init_taskbar(screen,
        tasklist, layout_box)
end

function taglist_table.create_tag_list(screen)
    local taglist = awful.widget.taglist {
        screen          = screen,
        filter          = awful.widget.taglist.filter.all,
        align           = "top",
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

function taglist_table.create_layout_box(screen)
    -- Layoutbox (смена лейаута)
    local layoutbox = awful.widget.layoutbox {
        screen = screen,
    }
    layoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end)
    ))
    return layoutbox
end

function taglist_table.init_taskbar(screen, tasklist, layout_box)
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
        nil,
        layout_box,
    }
end

return taglist_table
