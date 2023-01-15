-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
-- pcall(require, "luarocks.loader")

local globals = require("global_settings")

-- glob variables
local awesome = _G.awesome
local root = _G.root
local screen = _G.screen


local panel_size = globals.panel_size
local panel_position = globals.panel_position
local terminal = globals.terminal

-- Theme handling library
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
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

local common = require("common")

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
        common.set_wallpaper(current_screen)

        -- Each screen has its own tag table.
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, current_screen, awful.layout.layouts[1])

        _G.cosy_init_screen(current_screen)
    end
)
-- }}}

-- {{{
require("signals")
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
