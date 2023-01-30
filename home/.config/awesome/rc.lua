local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")

local beautiful = require("beautiful")

local naughty = require("naughty")
local menubar = require("menubar")
require("awful.hotkeys_popup.keys")

local theme_management = require("theme_management.common")


local d = require("dbg")

local awesome = _G.awesome
local client = _G.client
local root = _G.root
local screen = _G.screen

awesome.set_preferred_icon_size(512)


if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors
        }
    )
end

do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function (err)
            if in_error then return end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end

beautiful.init(theme_management.get_theme())

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

local config_defaults = require("configs.config_defaults")
menubar.utils.terminal = config_defaults.terminal

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", theme_management.set_wallpaper)

local init_screen = require("screen.init_screen")

local panel_widgets_ = require("widgets.panel_widgets")

local textclock_widget = panel_widgets_.init_textclock_widget()
local cpu_widget = panel_widgets_.init_cpu_widget()
local volume_widget = panel_widgets_.init_volume_widget()

local panel_widgets = {
    textclock_widget,
    cpu_widget,
    volume_widget
}

awful.screen.connect_for_each_screen(function(this_screen)
    theme_management.set_wallpaper(this_screen)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, this_screen, awful.layout.layouts[1])

    init_screen(this_screen, panel_widgets)
end)


-- {{{ Bindings
local menu = require("menu")
local set_mouse_bindings = require("keybindings.mouse_bindings")
local mouse_bindings = set_mouse_bindings(menu)

local set_keyboard_bindings = require("keybindings.bindings")
local keyboard_bindings = set_keyboard_bindings(menu)

local add_tags_bindings = require("keybindings.panel_bindings")
keyboard_bindings = add_tags_bindings(keyboard_bindings)

local init_volume_widget_bindings = require("keybindings.volume_widget_bindings")
local volume_bindings = init_volume_widget_bindings(volume_widget)

keyboard_bindings = gears.table.join(
    volume_bindings,
    keyboard_bindings
)
-- Set keys
root.buttons(mouse_bindings)
root.keys(keyboard_bindings)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
local create_rules = require("rules")
awful.rules.rules = create_rules()
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
    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    "request::titlebars",
    function(this_client)
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button({ }, 1, function()
                this_client:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.move(this_client)
            end),
            awful.button({ }, 3, function()
                this_client:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.resize(this_client)
            end)
        )

        awful.titlebar(this_client) : setup {
            { -- Left
                awful.titlebar.widget.iconwidget(this_client),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(this_client)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton (this_client),
                awful.titlebar.widget.maximizedbutton(this_client),
                awful.titlebar.widget.stickybutton   (this_client),
                awful.titlebar.widget.ontopbutton    (this_client),
                awful.titlebar.widget.closebutton    (this_client),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

local startups = require("startup")
for _, func in pairs(startups) do
    func()
end