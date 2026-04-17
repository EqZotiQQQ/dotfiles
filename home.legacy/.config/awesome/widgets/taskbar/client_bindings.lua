local awful = require("awful")
local gears = require("gears")

local bindings = {}


bindings.tasklist_bindings = {
    awful.button(
        {},
        1,
        function(c)
            c:activate {
                context = "tasklist",
                action = "toggle_minimization"
            }
        end
    ),
    awful.button(
        {},
        3,
        function()
            awful.menu.client_list {
                theme = {
                    width = 250
                }
            }
        end
    ),
    awful.button(
        {},
        4,
        function()
            awful.client.focus.byidx(-1)
        end
    ),
    awful.button(
        {},
        5,
        function()
            awful.client.focus.byidx(1)
        end
    )
}

return bindings
