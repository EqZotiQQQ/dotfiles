local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local cosy = require("cosy")
local beautiful = require("beautiful")
local panel_config = require("panel_config")
local d = require("dbg")
local keybindings = require("keybindings")
local volume_widget = require("widgets.volume-widget.volume")
local common = require("common")
local dpi = require("beautiful").xresources.apply_dpi
local screen = _G.screen
local details = require("details")


-- Keyboard map indicator and switcher
local keyboardlayout = awful.widget.keyboardlayout()

function _G.cosy_init_screen(current_screen)
    current_screen.cava = cosy.widget.desktop.cava(
        current_screen,
        {
            bars = panel_config.cava_config.bars,
            enable_interpolation = panel_config.cava_config.interpolation,
            size = panel_config.panel_size,
            position = panel_config.actual_position,
            update_time = panel_config.cava_config.update_time,
        }
    )

    local panel_offset = {
        x = panel_config.actual_position == "left" and panel_config.panel_size or 0,
        y = panel_config.actual_position == "top" and panel_config.panel_size or 0,
    }

    current_screen.rings = cosy.widget.desktop.rings(
        current_screen,
        {
            x = panel_offset.x + 25, -- ring position X
            y = panel_offset.y + 20  -- ring position Y
        }
    )

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    current_screen.layoutbox = awful.widget.layoutbox(current_screen)
    current_screen.layoutbox:buttons(
        gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)
        )
    )

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
        (panel_config.actual_position == details.position.left or
            panel_config.actual_position == details.position.right)
        and details.orientation.vertical
        or details.orientation.horizontal

    -- Create a taglist widget
    current_screen.taglist = awful.widget.taglist {
        screen = current_screen,
        filter = awful.widget.taglist.filter.noempty,
        buttons = keybindings.taglist_mouse,
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
        buttons = keybindings.tasklist_mouse,
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

    if panel_config.actual_position == details.position.left or panel_config.actual_position == details.position.right then
        panel_properties.width = panel_config.panel_size
    else
        panel_properties.height = panel_config.panel_size
    end

    -- create new panel
    current_screen.panel = awful.wibar(panel_properties)

    -- Add widgets to the wibox
    current_screen.panel:setup {
        layout = wibox.layout.align[panel_orientation],
        { -- Left widgets
            layout = wibox.layout.fixed[panel_orientation],
            screen.mytaglist,
            current_screen.taglist,
        },
        current_screen.tasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed[panel_orientation],
            cosy.widget.panel.volume(
                {
                    indicator_width = dpi(2),
                    indicator_offset = dpi(5),
                }
            ),
            keyboardlayout,
            current_screen.systray,
            cosy.widget.textclock,
            current_screen.layoutbox,
            volume_widget{
                widget_type = 'arc',
                refresh_rate = 0.1
            },
        },
    }
end

local function connect_for_each_screen()
    awful.screen.connect_for_each_screen(
        function(current_screen)
            common.set_wallpaper(current_screen)

            -- Each screen has its own tag table.
            awful.tag(
                {
                    "1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                },
                current_screen,
                awful.layout.layouts[1]
            )

            _G.cosy_init_screen(current_screen)
        end
    )
end

return connect_for_each_screen