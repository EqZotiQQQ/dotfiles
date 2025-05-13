local gears      = require("gears")
local debug      = require("dbg")
local utils      = require("lib.helpers")
local signals    = require("system.signals")

local file_utils = utils.file

local function get_default_cpu_load()
    return {
        used = 0,
        user = 0,
        nice = 0,
        system = 0,
        idle = 0,
        iowait = 0,
        irq = 0,
        softirq = 0,
        steal = 0,
        guest = 0,
        guest_nice = 0,
    }
end

local CPUWatchdog = {}

CPUWatchdog.__index = CPUWatchdog

function CPUWatchdog:new()
    local watchdog = setmetatable({}, self)
    -- Total core count
    watchdog.cpu_count = 0
    -- CPU usage per core
    watchdog.load = {
        total = {},
        _prev = nil,
        _this = nil,
    }
    -- Virtual to physical core id
    watchdog.proc_to_core = {}

    watchdog.proc_to_core, watchdog.cpu_count = watchdog:get_cpu_info()

    watchdog.load.total = get_default_cpu_load()
    for i = 1, watchdog.cpu_count do
        watchdog.load[i] = get_default_cpu_load()
    end

    watchdog:update()
    signals.emit_signal("cpu::updated")

    return watchdog
end

function CPUWatchdog:get_cpu_info()
    local cpuinfo = file_utils.read("/proc/cpuinfo")
    local cpu_count = 0
    local proc_to_core = {}
    for procinfo in cpuinfo:gmatch(".-\n\n") do
        local id, coreid = procinfo:match(
            "processor%s+:%s+(%d+).*" ..
            "core id%s+:%s+(%d+).*"
        )

        proc_to_core[id] = coreid
        cpu_count = cpu_count + 1
    end

    return proc_to_core, cpu_count
end

function CPUWatchdog:register_timer(cooldown)
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

function CPUWatchdog:update()
    self:update_load()
    -- debug.stdout(self.load)
end

function CPUWatchdog:update_load()
    self.load._prev = self.load._this
    self.load._this = {}

    local stat = file_utils.read("/proc/stat")

    for core, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
    in stat:gmatch("cpu(%d*)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    do
        if core == "" then
            core = "total"
        else
            core = tonumber(core) + 1
        end

        self.load._this[core] = {
            user       = tonumber(user),
            nice       = tonumber(nice),
            system     = tonumber(system),
            idle       = tonumber(idle),
            iowait     = tonumber(iowait),
            irq        = tonumber(irq),
            softirq    = tonumber(softirq),
            steal      = tonumber(steal),
            guest      = tonumber(guest),
            guest_nice = tonumber(guest_nice),
        }

        if self.load._prev ~= nil and self.load._prev[core] ~= nil then
            local prev_total = 0
            for _, val in pairs(self.load._prev[core]) do
                prev_total = prev_total + val
            end

            local this_total = 0
            for _, val in pairs(self.load._this[core]) do
                this_total = this_total + val
            end

            local total = this_total - prev_total

            local prev_unused = self.load._prev[core].idle + self.load._prev[core].iowait
            local this_unused = self.load._this[core].idle + self.load._this[core].iowait
            self.load[core].used = (total + prev_unused - this_unused) / total

            self.load[core].user = (self.load._this[core].user - self.load._prev[core].user) / total
            self.load[core].nice = (self.load._this[core].nice - self.load._prev[core].nice) / total
            self.load[core].system = (self.load._this[core].system - self.load._prev[core].system) / total
            self.load[core].idle = (self.load._this[core].idle - self.load._prev[core].idle) / total
            self.load[core].iowait = (self.load._this[core].iowait - self.load._prev[core].iowait) / total
            self.load[core].irq = (self.load._this[core].irq - self.load._prev[core].irq) / total
            self.load[core].softirq = (self.load._this[core].softirq - self.load._prev[core].softirq) / total
            self.load[core].steal = (self.load._this[core].steal - self.load._prev[core].steal) / total
            self.load[core].guest = (self.load._this[core].guest - self.load._prev[core].guest) / total
            self.load[core].guest_nice = (self.load._this[core].guest_nice - self.load._prev[core].guest_nice) / total
        end
    end
end

return CPUWatchdog
