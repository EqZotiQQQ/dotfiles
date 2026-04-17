local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup")

local keybindings = {}

local keyboard_bindings = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),

    awful.key({ modkey }, "n",
        function(c)
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),

    awful.key({ modkey }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "maximize", group = "client" })
)

local mouse_bindings = gears.table.join(
    awful.button({}, 1, function(c)
        c:activate { context = "mouse_click" }
    end),
    awful.button({ modkey }, 1, function(c)
        c:activate { context = "mouse_click", action = "mouse_move" }
    end),
    awful.button({ modkey }, 3, function(c)
        c:activate { context = "mouse_click", action = "mouse_resize" }
    end)
)

keybindings.mouse_bindings = mouse_bindings
keybindings.keyboard_bindings = keyboard_bindings

return keybindings
