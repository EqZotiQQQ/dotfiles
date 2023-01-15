-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
-- pcall(require, "luarocks.loader")

local globals = require("global_settings")

-- glob variables
local awesome = _G.awesome
local client = _G.client
local root = _G.root
local tag = _G.tag
local screen = _G.screen


local panel_size = globals.panel_size
local panel_position = globals.panel_position
local terminal = globals.terminal

-- Theme handling library
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local layout = require("layout")
beautiful.init(globals.theme_dir .. "/theme.lua")

awesome.set_preferred_icon_size(64)

-- https://awesomewm.org/apidoc/core_components/screen.html


-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- User library
local cosy = require("cosy")

local client_signals = require("signals.client_signals")
local d = require("cosy.dbg")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- keybindings
local keybindings = require("keybindings")

-- Setup rules
require("rules")

-- Vol widget
local volume_widget = require("widgets.volume-widget.volume")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
        client_signals.debug.error,
        function (err)
            -- Make sure we don't go into an endless error loop
            if in_error then
                return
            end
            in_error = true

            naughty.notify({
                preset = naughty.config.presets.critical,
                title = "Oops, an error happened!",
                text = tostring(err)
            })
            in_error = false
        end
    )
end
-- }}}


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.max,
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

local function set_wallpaper(current_screen)
    d.notify("set_wallpaper")
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(current_screen)
        end
        gears.wallpaper.maximized(wallpaper, current_screen, true)
    end
end

-- Set keys
root.buttons(keybindings.mouse.global)
root.keys(keybindings.keyboard.global)
--

-- Keyboard map indicator and switcher
local keyboardlayout = awful.widget.keyboardlayout()

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal("property::geometry", cosy.util.set_wallpaper)

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
        set_wallpaper(current_screen)

        -- Each screen has its own tag table.
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, current_screen, awful.layout.layouts[1])

        _G.cosy_init_screen(current_screen)
    end
)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
    client_signals.on_manage,
    function (current_client)
        d.notify("manage")
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup
        and not current_client.size_hints.user_position
        and not current_client.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(current_client)
        end
    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    client_signals.request.titlebars,
    function(current_client)
        d.notify("request::titlebars")
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button({ }, 1,
                function()
                    current_client:emit_signal(
                        client_signals.request.activate,
                        "titlebar",
                        {
                            raise = true
                        }
                    )
                    awful.mouse.client.move(current_client)
                end
            ),
            awful.button({ }, 3,
                function()
                    current_client:emit_signal(
                        client_signals.request.activate,
                        "titlebar",
                        {
                            raise = true
                        }
                    )
                    awful.mouse.client.resize(current_client)
                end
            )
        )

        awful.titlebar(current_client) : setup {
            { -- Left
                awful.titlebar.widget.iconwidget(current_client),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(current_client)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton (current_client),
                awful.titlebar.widget.maximizedbutton(current_client),
                awful.titlebar.widget.stickybutton   (current_client),
                awful.titlebar.widget.ontopbutton    (current_client),
                awful.titlebar.widget.closebutton    (current_client),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
    client_signals.mouse.on_enter,
    function(current_client)
        d.notify("mouse::enter")
        current_client:emit_signal(
            client_signals.request.activate,
            "mouse_enter",
            {
                raise = false
            }
        )
    end
)

client.connect_signal(
    client_signals.on_focus,
    function(current_client)
        d.notify("focus")
        current_client.border_color = beautiful.border_focus
    end
)
client.connect_signal(
    client_signals.on_unfocus,
    function(current_client)
        d.notify("unfocus")
        current_client.border_color = beautiful.border_normal
    end
)

local floatgeoms = {}

client.connect_signal(
    client_signals.on_manage,
    function (current_client)
        d.notify("manage")
        -- Set the windows at the slave,
        if not awesome.startup then awful.client.setslave(current_client) end

        -- Set floating if slave window is created on popup layout
        -- TODO: Consider if more elegant solution is possible
        if awful.layout.get(current_client.screen) == layout.popup
            and cosy.util.table_count(current_client.first_tag:clients()) > 1
        then
            current_client.floating = true
            awful.placement.no_offscreen(current_client)
        end

        -- Save floating client geometry
        if cosy.util.client_free_floating(current_client) then
            floatgeoms[current_client.window] = current_client:geometry()
        end

        if awesome.startup
            and not current_client.size_hints.user_position
            and not current_client.size_hints.program_position
        then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(current_client)
        end
    end
)

-- FIXME: Exclude titlebar from geometry
-- XXX: There seems to be a weird behavior with property::floating signal. It is not sent when maximized and fullscreen
-- property changes of clients originally created on other than floating tag layouts and sent otherwise
client.connect_signal(
    client_signals.property.floating,
    function(current_client)
        d.notify("property::floating")
        if cosy.util.client_free_floating(current_client) then
            current_client:geometry(floatgeoms[current_client.window])
        end
        cosy.util.manage_titlebar(current_client)
    end
)

tag.connect_signal(
    client_signals.property.layout,
    function(current_tag)
        d.notify("property::layout")
        for _, current_client in pairs(current_tag:clients()) do
            if cosy.util.client_free_floating(current_client) then
                current_client:geometry(floatgeoms[current_client.window])
            end
            cosy.util.manage_titlebar(current_client)
        end
    end
)

client.connect_signal(
    client_signals.property.geometry,
    function(current_client)
        d.notify("property::geometry")
        if cosy.util.client_free_floating(current_client) then
            floatgeoms[current_client.window] = current_client:geometry()
        end
    end
)

client.connect_signal(
    client_signals.on_unmanage,
    function(current_client)
        d.notify("unmanage")
        floatgeoms[current_client.window] = nil
        awful.client.focus.byidx(-1)
    end
)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal(
    client_signals.property.geometry,
    set_wallpaper
)

-- }}}

-- Autostart
-- awful.spawn.with_shell("app --some-flags")

local hour = os.date("*t").hour
local wday = os.date("*t").wday

if (hour < 9 and hour > 18) or wday > 6 then
    awful.spawn.once("discord")
end
if (hour > 9 and hour < 18) and wday < 6 then
    awful.spawn.once("mattermost-desktop")
end

awful.spawn.once("telegram-desktop")
awful.spawn.once("flameshot")
awful.spawn.once("picom")

-- Keyboard layout
awful.spawn.spawn("setxkbmap -layout us,ru, -option 'grp:ctrl_shift_toggle'")
