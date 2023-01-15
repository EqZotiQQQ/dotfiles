local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local cosy = require("cosy")
local beautiful = require("beautiful")
local globals = require("global_settings")
local panel_size = globals.panel_size
local panel_position = globals.panel_position
local d = require("cosy.dbg")
local keybindings = require("keybindings")
local volume_widget = require("widgets.volume-widget.volume")
local common = require("common")
local dpi = require("beautiful.xresources").apply_dpi
local screen = _G.screen

-- Keyboard map indicator and switcher
local keyboardlayout = awful.widget.keyboardlayout()

function _G.cosy_init_screen(current_screen)
    d.notify("_G.cosy_init_screen")
    current_screen.cava = cosy.widget.desktop.cava(
        current_screen,
        {
            bars = 100,
            enable_interpolation = true,
            size = panel_size,
            position = panel_position,
            update_time = 0.05
        })

    -- local panel_offset = {
    --     x = panel_position == "left" and panel_size or 0,
    --     y = panel_position == "top" and panel_size or 0,
    -- }

    -- s.rings = cosy.widget.desktop.rings(
    --     s,
    --     {
    --         x = panel_offset.x + 25, -- ring position X
    --         y = panel_offset.y + 20  -- ring position Y
    --     }
    -- )

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
            to = {panel_size, 0},
            stops = { {0, beautiful.bg_focus.."f0"}, {1, beautiful.bg_focus.."00"} }
        }
    )

    local panel_orientation =
        (panel_position == "left" or panel_position == "right")
        and "vertical"
        or "horizontal"

    -- Create a taglist widget
    current_screen.taglist = awful.widget.taglist {
        screen = current_screen,
        filter = awful.widget.taglist.filter.noempty,
        buttons = keybindings.taglist_mouse,
        style = {
            align = "center",
            bg_normal = beautiful.bg_normal .. "a0",
            bg_focus = focus_gradient,
            bg_urgent = beautiful.bg_urgent .. "00",
        },
        layout = wibox.layout.fixed[panel_orientation](),
    }

    -- Create a tasklist widget
    current_screen.tasklist = awful.widget.tasklist {
        screen = current_screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = keybindings.tasklist_mouse,
        style = {
            align = "center",
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
        position = panel_position,
        bg = beautiful.bg_normal .. "a0", -- bg with alpha
    }

    if panel_position == "left" or panel_position == "right" then
        panel_properties.width = panel_size
    else
        panel_properties.height = panel_size
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
            cosy.widget.panel.volume({
                indicator_width = dpi(2),
                indicator_offset = dpi(5),
            }),
            keyboardlayout,
            current_screen.systray,
            cosy.widget.textclock,
            current_screen.layoutbox,
            volume_widget{widget_type = 'arc'}, -- customized
        },
    }
end

awful.screen.connect_for_each_screen(
    function(current_screen)
        d.notify("awful.screen.connect_for_each_screen")
        -- Wallpaper
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
