local d = require("dbg")

local awful = require("awful")

local tray = require("configs.tray")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local panel_widgets_ = require("widget.panel_widgets")
local screen_widgets_ = require("widget.screen_widgets")
local textclock_widget = panel_widgets_.init_textclock_widget()
local cpu_widget = panel_widgets_.init_cpu_widget()
local volume_widget = panel_widgets_.init_volume_widget()

local theme_utils = require("theme.utils")
local taglist_mouse_bindings = require("keybindings.taglist_mouse_bindings")
local tasklist_mouse_bindings = require("keybindings.tasklist_mouse_bindings")
local layoutbox_mouse_bindings = require("keybindings.layoutbox_mouse_bindings")

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

awful.screen.connect_for_each_screen(
    function(current_screen)
        
        theme_utils.set_wallpaper(current_screen)

        -- Each screen has its own tag table.
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, current_screen, awful.layout.layouts[1])

        local cava = screen_widgets_.init_cava(current_screen)

        local screen_widgets = {
            cava = cava,
        }

        for name, value in pairs(screen_widgets) do
            current_screen[name] = value
        end

        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        current_screen.layoutbox = awful.widget.layoutbox(current_screen)
        current_screen.layoutbox:buttons(layoutbox_mouse_bindings)

        local focus_gradient = gears.color.create_linear_pattern(
            {
                type = "linear",
                from = {0, 0},
                to = {tray.size, 0},
                stops = {
                    {0, beautiful.bg_focus.."f0"},
                    -- {1, beautiful.bg_focus.."00"}
                    {1, beautiful.bg_focus.."f0"}
                }
            }
        )

        local panel_orientation =
            (tray.position == "left" or
            tray.position == "right")
            and "vertical"
            or "horizontal"

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
    
        if tray.position == "left" or tray.position == "right" then
            panel_properties.width = tray.size
        else
            panel_properties.height = tray.size
        end
    
        -- create new panel
        current_screen.panel = awful.wibar(panel_properties)
    
        local systray = current_screen.systray

        

        local layout_box = current_screen.layoutbox
        local keyboardlayout = awful.widget.keyboardlayout()
    
        if current_screen.index == 1 then
            local network = require("widget.network")()
            local cpu_usage = require("widget.cpu_info")("usage")
            -- local cpu_temp = require("widget.cpu_info")("temp")
            local cpu_freq = require("widget.cpu_info")("freq", "average")
            local left_widgets = gears.table.join(
                {
                    layout = wibox.layout.fixed[panel_orientation],
                    current_screen.taglist,
                }
            )
        
            local right_widgets = gears.table.join(
                {
                    layout = wibox.layout.fixed[panel_orientation],
                    network,
                    cpu_usage,
                    cpu_freq,
                    -- cpu_temp,
                    systray,
                    keyboardlayout,
                },
                {
                    textclock_widget,
                    cpu_widget,
                    volume_widget.widget,
                },
                {
                    layout_box,
                }
            )

            current_screen.panel:setup {
                layout = wibox.layout.align[panel_orientation],
                left_widgets,
                current_screen.tasklist, -- Middle widget
                right_widgets
            }
        else -- second, third, ... monitors
            local left_widgets = gears.table.join(
                {
                    layout = wibox.layout.fixed[panel_orientation],
                    current_screen.taglist,
                }
            )
        
            local right_widgets = gears.table.join(
                {
                    layout = wibox.layout.fixed[panel_orientation],
                },
                {},
                {
                    layout_box,
                }
            )

            current_screen.panel:setup {
                layout = wibox.layout.align[panel_orientation],
                left_widgets,
                current_screen.tasklist, -- Middle widget
                right_widgets
            }
        end
    end
)