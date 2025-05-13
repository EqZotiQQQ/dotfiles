local gears        = require("gears")
local debug        = require("dbg")
local utils        = require("lib.helpers")
local signals      = require("system.signals")

local interface    = "enp6s0"

local NetMonitor   = {}
NetMonitor.__index = NetMonitor


function NetMonitor:new()
    local watchdog = setmetatable({}, self)
    watchdog.prev_rx = 0
    watchdog.prev_tx = 0
    watchdog.prev_time = os.time()

    watchdog.c_up = 0
    watchdog.c_down = 0
    return watchdog
end

function NetMonitor:register_timer(cooldown)
    if type(cooldown) ~= "number" then
        cooldown = 1
    end

    self.update_timer = gears.timer.start_new(
        cooldown,
        function()
            self:update()
            signals.emit_signal("cpu::updated")
            return true
        end
    )
end

function NetMonitor:read_interface_data()
    local fp = io.open("/proc/net/dev", "r")
    if not fp then return nil end
    for line in fp:lines() do
        if line:match(interface) then
            --  enp6s0: 1328981725 17894 0 0 0 0 0 0 34742398 19233 0 0 0 0 0 0
            local values = {}
            for val in line:gmatch("%d+") do
                table.insert(values, tonumber(val))
            end
            local rx_bytes = values[1]
            local tx_bytes = values[9]
            fp:close()
            return rx_bytes, tx_bytes
        end
    end
    fp:close()
    return nil
end

function NetMonitor:get_speed()
    local now = os.time()
    local rx, tx = self:read_interface_data()
    if not rx or not tx then return "N/A", "N/A" end

    local dt = now - self.prev_time
    if dt == 0 then dt = 1 end

    local down     = (rx - self.prev_rx) / dt
    local up       = (tx - self.prev_tx) / dt

    self.prev_rx   = rx
    self.prev_tx   = tx
    self.prev_time = now

    self.c_up      = up
    self.c_down    = down

    return { up = up / 1024, down = down / 1024 }
    -- return string.format("%.1f KB/s", down / 1024), string.format("%.1f KB/s", up / 1024)
end

function NetMonitor:update()
    local speed = self:get_speed()
    debug.stdout(speed)
end

return NetMonitor
