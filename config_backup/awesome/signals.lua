local client = _G.client
local awesome = _G.awesome
local tag = _G.tag
local screen = _G.screen

local naughty = require("naughty")
local client_signals = require("signals.client_signals")

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local d = require("dbg")
local util = require("util")

local layout = require("layout")
local beautiful = require("beautiful")

local signals = {}

signals.on_client_creation = function ()
    client.connect_signal(
        client_signals.on_manage,
        function (current_client)
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
end

signals.on_request_titlebars = function ()
    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    client.connect_signal(
        client_signals.request.titlebars,
        function(current_client)
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
end

signals.on_mouse_enter = function ()
    client.connect_signal(
        client_signals.mouse.on_enter,
        function(current_client)
            current_client:emit_signal(
                client_signals.request.activate,
                "mouse_enter",
                {
                    raise = false
                }
            )
        end
    )
end

signals.on_client_focus = function ()
    client.connect_signal(
        client_signals.on_focus,
        function(current_client)
            current_client.border_color = beautiful.border_focus
        end
    )
end

signals.on_unfocus = function ()
    client.connect_signal(
        client_signals.on_unfocus,
        function(current_client)
            current_client.border_color = beautiful.border_normal
        end
    )
end

local floatgeoms = {}

signals.on_manage = function ()
    client.connect_signal(
        client_signals.on_manage,
        function (current_client)
            -- Set the windows at the slave,
            if not awesome.startup then
                awful.client.setslave(current_client)
            end

            -- Set floating if slave window is created on popup layout
            -- TODO: Consider if more elegant solution is possible
            if awful.layout.get(current_client.screen) == layout.popup
                and util.table_count(current_client.first_tag:clients()) > 1
            then
                current_client.floating = true
                awful.placement.no_offscreen(current_client)
            end

            -- Save floating client geometry
            if util.client_free_floating(current_client) then
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
end

-- FIXME: Exclude titlebar from geometry
-- XXX: There seems to be a weird behavior with property::floating signal. It is not sent when maximized and fullscreen
-- property changes of clients originally created on other than floating tag layouts and sent otherwise
signals.on_client_floating = function ()
    client.connect_signal(
        client_signals.property.floating,
        function(current_client)
            if util.client_free_floating(current_client) then
                current_client:geometry(floatgeoms[current_client.window])
            end
            util.manage_titlebar(current_client)
        end
    )
end

signals.on_property_layout = function ()
    tag.connect_signal(
        client_signals.property.layout,
        function(current_tag)
            for _, current_client in pairs(current_tag:clients()) do
                if util.client_free_floating(current_client) then
                    current_client:geometry(floatgeoms[current_client.window])
                end
                util.manage_titlebar(current_client)
            end
        end
    )
end

signals.on_client_geometry_change = function ()
    client.connect_signal(
        client_signals.property.geometry,
        function(current_client)
            if util.client_free_floating(current_client) then
                floatgeoms[current_client.window] = current_client:geometry()
            end
        end
    )
end

signals.on_client_destroy = function ()
    client.connect_signal(
        client_signals.on_unmanage,
        function(current_client)
            floatgeoms[current_client.window] = nil
            awful.client.focus.byidx(-1)
        end
    )
end

signals.on_resolution_change = function ()
    screen.connect_signal(
        client_signals.property.geometry,
        util.set_wallpaper
    )
end

signals.on_error_signal = function()
    local in_error = false
    awesome.connect_signal(
        client_signals.debug.error,
        function (err)
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

return signals
