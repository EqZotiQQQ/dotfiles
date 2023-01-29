local awful = require("awful")
local gears = require("gears")
local modkey = require("configs.config_defaults").modkey

local function init_volume_widget_bindings(volume_widget, keybindings)
    return gears.table.join(
        keybindings,
        awful.key({ modkey }, "]", function() volume_widget:inc(5)   end, {description = "Increase sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "[", function() volume_widget:dec(5)   end, {description = "Decrease sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "\\",function() volume_widget:toggle() end, {description = "Mute out sound",               group = "media" })
    )
end

return init_volume_widget_bindings