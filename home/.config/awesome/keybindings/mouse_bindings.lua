local awful = require("awful")
local gears = require("gears")

local set_mouse_bindings = function (mymainmenu)
    local mouse_bindings = gears.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    )
    return mouse_bindings
end

return set_mouse_bindings