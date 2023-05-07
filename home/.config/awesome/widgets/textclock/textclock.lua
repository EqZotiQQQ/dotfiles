local wibox = require("wibox")
local d = require("dbg")

local t = {}

t.mt = {}

function t.new(arg)
    local textclock = {}
    textclock.widget = wibox.widget.textclock("<span font=\"Iosevka 10\">%a\n%H:%M\n%d/%m</span>")
    textclock.widget:set_align("center")
    return textclock
end

function t.mt:__call(...)
    return t.new(...)
end

return setmetatable(t, t.mt)
