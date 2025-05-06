local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local mouse_bindings = require("widgets.mouse_bindings")
local theme = require("themes.default.theme")

local m = {}

function m.full_init_taskbar(screen)
    local tasklist = m.create_tasklist(screen)
    local taglist = m.create_taglist(screen)
    local layout_box = m.create_layout_box(screen)
    local prompt_box = m.create_prompt_box()
    m.init_taskbar(screen, tasklist, taglist, layout_box, prompt_box)
end

function m.create_tasklist(screen)
    -- Create a tasklist widget
    local mytasklist =
        awful.widget.tasklist {
            screen = screen,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = mouse_bindings.tasklist_bindings
        }
    return mytasklist
end

function m.create_taglist(screen)
    -- Create a taglist widget
    local mytaglist =
        awful.widget.taglist {
            screen  = screen,
            filter  = awful.widget.taglist.filter.all,
            buttons = mouse_bindings.tags_navigation,
            layout  = {
                spacing = 5,
                layout  = wibox.layout.fixed.vertical,
            },
        }
    return mytaglist
end

function m.create_layout_box(screen)
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    local mylayoutbox =
        awful.widget.layoutbox {
            screen = screen,
            buttons = mouse_bindings.layout_control
        }
    return mylayoutbox
end

function m.create_prompt_box()
    -- Create a promptbox for each screen
    local mypromptbox = awful.widget.prompt()
    return mypromptbox
end

function m.init_taskbar(screen, layout_box, tag_list, task_list, prompt_box)
    -- Create the wibox
    local left_taskbar = awful.wibar(
        {
            bg = theme.taskbar_config.color_bg,
            fg = theme.taskbar_config.color_fg,
            -- height = theme.taskbar_config.height,
            position = "left",
            screen = screen,
            widget = {
                layout = wibox.layout.align.horizontal,
                -- layout = wibox.layout.align.vertical,
                {
                    -- Left widgets
                    layout = wibox.layout.fixed.vertical,
                    -- mylauncher,
                    tag_list,
                    prompt_box
                },
                task_list, -- Middle widget
                {
                    -- Right widgets
                    layout = wibox.layout.fixed.vertical,
                    -- mykeyboardlayout,
                    -- wibox.widget.systray(),
                    -- mytextclock,
                    layout_box
                }
            }
        }
    )
end

return m
