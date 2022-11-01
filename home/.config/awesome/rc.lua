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

-- Theme handling library
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local layout = require("layout")
local theme_dir = globals.theme_dir
beautiful.init(theme_dir .. "/theme.lua")

awesome.set_preferred_icon_size(64)

-- https://awesomewm.org/apidoc/core_components/screen.html

local terminal = globals.terminal

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")


-- Notification library
local naughty = require("naughty")
-- naughty.notify({ title = "Hello!", text = "You're idling\t".. theme_config_file, timeout = 0 })

local menubar = require("menubar")

local menu = require("menu")

-- User library
local cosy = require("cosy")


-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- keybindings
local keybindings = require("keybindings")

-- Setup rules
require("rules")

-- Vol widget
local volume_widget = require("widgets.volume-widget.volume")
local cpu_widget = require("widgets.cpu-widget.cpu-widget")

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
    awesome.connect_signal("debug::error",
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
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu

local launcher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = menu.main
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()


local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Set keys
root.buttons(keybindings.mouse.global)
root.keys(keybindings.keyboard.global)
--

-- Keyboard map indicator and switcher
local keyboardlayout = awful.widget.keyboardlayout()

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal("property::geometry", cosy.util.set_wallpaper)

function _G.init_screen(screen)

    -- Create a promptbox for each screen
    screen.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    screen.mylayoutbox = awful.widget.layoutbox(screen)
    screen.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    screen.mytaglist = awful.widget.taglist {
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        buttons = keybindings.taglist_mouse
    }

    -- Create a tasklist widget
    screen.mytasklist = awful.widget.tasklist {
        screen  = screen,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = keybindings.tasklist_mouse
    }

    -- Create the wibox
    screen.mywibox = awful.wibar({ position = "top", screen = screen })

    -- Add widgets to the wibox
    screen.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            launcher,
            screen.mytaglist,
            screen.mypromptbox,
        },
        screen.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            keyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            screen.mylayoutbox,
            cpu_widget(),
            volume_widget{widget_type = 'arc'}, -- customized
        },
    }
end

function _G.cosy_init_screen(s)
    s.cava = cosy.widget.desktop.cava(
        s,
        {
            bars = 100,
            enable_interpolation = true,
            size = panel_size,
            position = panel_position,
            update_time = 0.05
        })
    
    local panel_offset = {
        x = panel_position == "left" and panel_size or 0,
        y = panel_position == "top" and panel_size or 0,
    }
    s.rings = cosy.widget.desktop.rings(s, { x = panel_offset.x + 25, y = panel_offset.y + 20 })

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    local focus_gradient = gears.color.create_linear_pattern({
            type = "linear",
            from = {0, 0},
            to = {panel_size, 0},
            stops = { {0, beautiful.bg_focus.."f0"}, {1, beautiful.bg_focus.."00"} }
        })

    local panel_orientation =
        (panel_position == "left" or panel_position == "right")
        and "vertical"
        or "horizontal"

    -- Create a taglist widget
    s.taglist = awful.widget.taglist {
        screen = s,
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
    s.tasklist = awful.widget.tasklist {
        screen = s,
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

    s.systray = wibox.widget.systray()

    -- remove old panel
    if s.panel then s.panel:remove() end

    local panel_properties = {
        screen = s,
        position = panel_position,
        bg = beautiful.bg_normal .. "a0", -- bg with alpha
    }

    if panel_position == "left" or panel_position == "right" then
        panel_properties.width = panel_size
    else
        panel_properties.height = panel_size
    end

    -- create new panel
    s.panel = awful.wibar(panel_properties)

    -- Add widgets to the wibox
    s.panel:setup {
        layout = wibox.layout.align[panel_orientation],
        { -- Left widgets
            layout = wibox.layout.fixed[panel_orientation],
            screen.mytaglist,
            s.taglist,
        },
        s.tasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed[panel_orientation],
            cosy.widget.panel.volume({
                indicator_width = dpi(2),
                indicator_offset = dpi(5),
            }),
            -- cosy.widget.panel.battery({}),
            keyboardlayout,
            s.systray,
            cosy.widget.textclock,
            s.layoutbox,
            volume_widget{widget_type = 'arc'}, -- customized
        },
    }
end

awful.screen.connect_for_each_screen(function(screen)
    -- Wallpaper
    set_wallpaper(screen)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, screen, awful.layout.layouts[1])

    -- _G.init_screen(screen)
    _G.cosy_init_screen(screen)
end)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1,
            function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.move(c)
            end
        ),
        awful.button({ }, 3,
            function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.resize(c)
            end
        )
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter",
    function(c)
        c:emit_signal("request::activate", "mouse_enter", {raise = false})
    end
)

client.connect_signal("focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)

local floatgeoms = {}

client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    if not awesome.startup then awful.client.setslave(c) end

    -- Set floating if slave window is created on popup layout
    -- TODO: Consider if more elegant solution is possible
    if awful.layout.get(c.screen) == layout.popup
        and cosy.util.table_count(c.first_tag:clients()) > 1
    then
        c.floating = true
        awful.placement.no_offscreen(c)
    end

    -- Save floating client geometry
    if cosy.util.client_free_floating(c) then
        floatgeoms[c.window] = c:geometry()
    end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- FIXME: Exclude titlebar from geometry
-- XXX: There seems to be a weird behavior with property::floating signal. It is not sent when maximized and fullscreen
-- property changes of clients originally created on other than floating tag layouts and sent otherwise
client.connect_signal("property::floating", function(c)
    if cosy.util.client_free_floating(c) then
        c:geometry(floatgeoms[c.window])
    end
    cosy.util.manage_titlebar(c)
end)

tag.connect_signal("property::layout", function(t)
    for _, c in pairs(t:clients()) do
        if cosy.util.client_free_floating(c) then
            c:geometry(floatgeoms[c.window])
        end
        cosy.util.manage_titlebar(c)
    end
end)

client.connect_signal("property::geometry", function(c)
    if cosy.util.client_free_floating(c) then
        floatgeoms[c.window] = c:geometry()
    end
end)

client.connect_signal("unmanage", function(c)
    floatgeoms[c.window] = nil
    awful.client.focus.byidx(-1)
end)


-- }}}

-- Autostart
-- awful.spawn.with_shell("app --some-flags")

awful.spawn.spawn("setxkbmap -layout us,ru, -option 'grp:ctrl_shift_toggle'")


local time = os.date("*t")

if time.hour < 9 and time.hour > 18 then
    awful.spawn.once("telegram-desktop")
    awful.spawn.once("discord")
end
if time.hour > 9 and time.hour < 18 then
    awful.spawn.once("mattermost-desktop")
end

awful.spawn.once("flameshot")
awful.spawn.once("notion-snap")
awful.spawn.once("picom")

awful.spawn("xrandr --output DP-2 --primary --mode 2560x1440 --rate 239.96 --output DP-0 --mode 1920x1080")

-- Keyboard layout
-- kbdcfg.layout = { { "us", "" }, { "ru,us", "phonetic" } }
