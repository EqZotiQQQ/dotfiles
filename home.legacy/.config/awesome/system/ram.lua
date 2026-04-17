local gears         = require("gears")
local debug         = require("dbg")
local utils         = require("lib.helpers")
local signals       = require("system.signals")

local file_utils    = utils.file

local RAMWatchdog   = {
    -- -- Total RAM in kB
    -- total = 0,
    -- -- Free RAM in kB
    -- free = 0,
    -- -- Available RAM in kB
    -- available = 0,
}

RAMWatchdog.__index = RAMWatchdog

function RAMWatchdog:new()
    local watchdog = setmetatable({}, self)
    watchdog.total = 0
    watchdog.free = 0      -- Free RAM in kB
    watchdog.available = 0 -- Available RAM in kB
    return watchdog
end

function RAMWatchdog:register_timer(cooldown)
    if type(cooldown) ~= "number" then
        cooldown = 1
    end

    self.update_timer = gears.timer.start_new(
        cooldown,
        function()
            self:update()
            signals.emit_signal("ram::updated")
            return true
        end
    )
end

function RAMWatchdog:update()
    local stat = file_utils.read("/proc/meminfo")
    local total, free, avail = stat:match(
        "MemTotal:%s+(%d+).*" ..
        "MemFree:%s+(%d+).*" ..
        "MemAvailable:%s+(%d+).*"
    )
    self.total = tonumber(total)
    self.free = tonumber(free)
    self.available = tonumber(avail)
end

return RAMWatchdog
