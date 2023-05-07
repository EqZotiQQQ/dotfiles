-- Awesome stack
local awful = require("awful")
local awesome = _G.awesome

local awesome_common = {}

awesome_common.restart = function()
    awesome.restart()
end

awesome_common.quit = function()
    awesome.quit()
end

awesome_common.suspend = function ()
    awful.spawn("systemctl suspend")
end

awesome_common.power_off = function ()
    awful.spawn("shutdown 0")
end

awesome_common.get_script_location = function()
    return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

return awesome_common