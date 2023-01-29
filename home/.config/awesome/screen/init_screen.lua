local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

local panel_positions = require("presets.panel_position")
local panel_orientations = require("presets.panel_orientations")

local taglist_mouse_bindings = require("keybindings.taglist_mouse_bindings")
local tasklist_mouse_bindings = require("keybindings.tasklist_mouse_bindings")
local layout_mouse_bindings = require("keybindings.layout_mouse_bindings")

local panel_config = require("configs.panel")

local clock_widget = require("widgets.panel.textclock.textclock")
local volume_widget = require("widgets.panel.volume-widget.volume")
local cava = require("widgets.screen.cava.cava")

local init_panel = function(current_screen)
    current_screen.cava = cava(
        current_screen,
        {
            bars = panel_config.cava_config.bars,
            enable_interpolation = panel_config.cava_config.interpolation,
            size = panel_config.panel_size,
            position = panel_config.actual_position,
            update_time = panel_config.cava_config.update_time,
        }
    )

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    current_screen.layoutbox = awful.widget.layoutbox(current_screen)
    current_screen.layoutbox:buttons(layout_mouse_bindings)

    local focus_gradient = gears.color.create_linear_pattern(
        {
            type = "linear",
            from = {0, 0},
            to = {panel_config.panel_size, 0},
            stops = {
                {0, beautiful.bg_focus.."f0"},
                {1, beautiful.bg_focus.."00"}
            }
        }
    )

    local panel_orientation =
        (panel_config.actual_position == panel_positions.left or
            panel_config.actual_position == panel_positions.right)
        and panel_orientations.vertical
        or panel_orientations.horizontal

    -- Create a taglist widget
    current_screen.taglist = awful.widget.taglist {
        screen = current_screen,
        filter = awful.widget.taglist.filter.noempty,
        buttons = taglist_mouse_bindings,
        style = {
            align = panel_config.align,
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
            align = panel_config.align,
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
        position = panel_config.actual_position,
        bg = beautiful.bg_normal .. "a0", -- bg with alpha
    }

    if panel_config.actual_position == panel_positions.left or panel_config.actual_position == panel_positions.right then
        panel_properties.width = panel_config.panel_size
    else
        panel_properties.height = panel_config.panel_size
    end

    -- create new panel
    current_screen.panel = awful.wibar(panel_properties)

    local systray = current_screen.systray
    local textclock_widget = clock_widget{}
    -- local cpu_widget = widgets.cpu_widget{}
    -- local net_widget = widgets.network_widgets.indicator{}
    local volume_widget = volume_widget{
        widget_type = 'vertical_bar', -- [] arc | vertical_bar ]
        refresh_rate = 0.1,
    }
    local layout_box = current_screen.layoutbox
    local keyboardlayout = awful.widget.keyboardlayout()
    -- d.notify_persistent(net_widget)
    -- Add widgets to the wibox
    current_screen.panel:setup {
        layout = wibox.layout.align[panel_orientation],
        { -- Left widgets
            layout = wibox.layout.fixed[panel_orientation],
            -- screen.mytaglist,
            current_screen.taglist,
        },
        current_screen.tasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed[panel_orientation],
            systray,
            keyboardlayout,
            textclock_widget,
            -- cpu_widget,
            -- net_widget,
            volume_widget,
            layout_box,
        },
    }
end

return init_panel