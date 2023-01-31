local awful = require("awful")
local gears = require("gears")
local modkey = require("configs.config_defaults").modkey

local audio = require("widgets.screen.cava.details.audio")

local d = require("dbg")

local function init_volume_widget_bindings()
    return gears.table.join(
        awful.key({ modkey }, "]", function() audio:volume_set("+5%")   end, {description = "Increase sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "[", function() audio:volume_set("-5%")   end, {description = "Decrease sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "\\",function() audio:toggle() end, {description = "Mute out sound",               group = "media" })
    )
end

return init_volume_widget_bindings