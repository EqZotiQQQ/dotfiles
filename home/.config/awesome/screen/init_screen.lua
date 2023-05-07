local d = require("dbg")

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

local panel_positions = require("presets.panel_position")
local panel_orientations = require("presets.panel_orientations")
local taglist_mouse_bindings = require("keybindings.taglist_mouse_bindings")
local tasklist_mouse_bindings = require("keybindings.tasklist_mouse_bindings")
local layout_mouse_bindings = require("keybindings.layout_mouse_bindings")

local tray = require("configs.tray")


local init_panel = function(current_screen, panel_widgets, screen_widgets)
    for name, value in pairs(screen_widgets) do
        current_screen[name] = value
    end

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    current_screen.layoutbox = awful.widget.layoutbox(current_screen)
    current_screen.layoutbox:buttons(layout_mouse_bindings)

    local focus_gradient = gears.color.create_linear_pattern(
        {
            type = "linear",
            from = {0, 0},
            to = {tray.size, 0},
            stops = {
                {0, beautiful.bg_focus.."f0"},
                {1, beautiful.bg_focus.."00"}
            }
        }
    )

    local panel_orientation =
        (tray.position == panel_positions.left or
        tray.position == panel_positions.right)
        and panel_orientations.vertical
        or panel_orientations.horizontal

    -- Create a taglist widget
    current_screen.taglist = awful.widget.taglist {
        screen = current_screen,
        filter = awful.widget.taglist.filter.noempty,
        buttons = taglist_mouse_bindings,
        style = {
            align = tray.align,
            bg_normal = beautiful.bg_normal .. "a0",
            bg_focus = focus_gradient,
            bg_urgent = beautiful.bg_urgent .. "00",
        },
        layout = wibox.layout.fixed[panel_orientation](),
    }

    -- Create a tasklist widget. Shows apps running on current_screen
    current_screen.tasklist = awful.widget.tasklist {
        screen = current_screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_mouse_bindings,
        style = {
            align = tray.align,
            disable_task_name = true,
            bg_normal = "#00000000",
            bg_focus = focus_gradient,
            bg_urgent = beautiful.bg_urgent .. "00",
        },
        layout = wibox.layout.fixed[panel_orientation]()
    }

    current_screen.systray = wibox.widget.systray()

    -- remove old panel
    if current_screen.panel then current_screen.panel:remove() end

    local panel_properties = {
        screen = current_screen,
        position = tray.position,
        bg = beautiful.bg_normal .. "a0", -- bg with alpha
    }

    if tray.position == panel_positions.left or tray.position == panel_positions.right then
        panel_properties.width = tray.size
    else
        panel_properties.height = tray.size
    end

    -- create new panel
    current_screen.panel = awful.wibar(panel_properties)

    local systray = current_screen.systray

    local layout_box = current_screen.layoutbox
    local keyboardlayout = awful.widget.keyboardlayout()

    local right_widgets = gears.table.join(
        { -- Right widgets
            layout = wibox.layout.fixed[panel_orientation],
            systray,
            keyboardlayout,
        },
        panel_widgets,
        {
            -- net_widget,
            layout_box,
            -- panel_widgets.textclock_widget,
        }
    )

    current_screen.panel:setup {
        layout = wibox.layout.align[panel_orientation],
        { -- Left widgets
            layout = wibox.layout.fixed[panel_orientation],
            -- screen.mytaglist,
            current_screen.taglist,
        },
        current_screen.tasklist, -- Middle widget
        right_widgets
    }
end

return init_panel