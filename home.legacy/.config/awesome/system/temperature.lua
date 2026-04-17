local gears                 = require("gears")
local awful                 = require("awful")
local debug                 = require("dbg")
local utils                 = require("lib.helpers")
local signals               = require("system.signals")

local file_utils            = utils.file

local TemperatureWatchdog   = {
    -- Temperature in millidegrees celcius per physical core
    -- cpu = {
    --     path = nil,
    --     core = {},
    -- },

}

TemperatureWatchdog.__index = TemperatureWatchdog

function TemperatureWatchdog:new()
    local watchdog = setmetatable({}, self)
    -- for line in io.popen("for x in /sys/class/hwmon/hwmon*; do printf \"%s \" $x; cat $x/name; done"):lines() do
    --     local path, name = line:match("([^%s]-)%s+([^\n]-)\n")
    --     if name == "coretemp" then
    --         watchdog.cpu.path = path
    --     end
    -- end
    watchdog.temp = 0
    return watchdog
end

function TemperatureWatchdog:register_timer(cooldown)
    if type(cooldown) ~= "number" then
        cooldown = 1
    end

    self.update_timer = gears.timer.start_new(
        cooldown,
        function()
            self:update_temp_using_sensors_lib()
            signals.emit_signal("temperature::updated")
            return true
        end
    )
end

function TemperatureWatchdog:update_temp_using_sensors_lib()
    awful.spawn.easy_async_with_shell("sensors", function(stdout)
        self.temp = stdout:match("Tctl:%s+%+([%d%.]+)°C") or "N/A"
        debug.stdout(self.temp)
    end)
end

-- function temp:update()
--     for line in io.popen("for x in /sys/class/hwmon/hwmon*; do printf \"%s \" $x; cat $x/name; done"):lines() do
--         local path, name = line:match("([^%s]-)%s+([^\n]-)\n")
--         debug.stdout(line)
--         debug.stdout(path)
--         if name == "coretemp" then
--             self.cpu.path = path
--         end
--     end
-- end

return TemperatureWatchdog
