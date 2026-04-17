local gears      = require("gears")
local debug      = require("dbg")
local utils      = require("lib.helpers")
local signals    = require("system.signals")

local file_utils = utils.file

local power      = {}

function power:init(update_time)
    if type(update_time) ~= "number" then
        update_time = 1
    end

    if self.initialized == true then
        -- If default timeout is different from 1, nil is denied by design to prevent
        -- external modules from load order errors
        if update_time ~= self.update_timer.timeout then
            error("cosy.system.status: Battery status on various timeouts is not yet implemented")
        else
            -- Already initialized
            return
        end
    end

    self.units = {}
    self.units.bat = {}
    self.units.ac = {}
    for line in io.popen("for x in /sys/class/power_supply/*; do printf \"%s \" $x; cat $x/type; done"):lines() do
        local name, type = line:match("/sys/class/power_supply/([^%s]-)%s+([^%s]+)")
        if type == "Battery" then
            self.units.bat[name] = {}
        else
            self.units.ac[name] = {}
        end
    end

    self:update()
    self:initialize_default_units()

    self.update_timer = gears.timer.start_new(
        update_time,
        function()
            self:update()
            signals.emit_signal("power::updated")
            return true
        end
    )

    self.initialized = true
end

function power:initialize_default_units()
    for _, bat in pairs(self.units.bat) do
        self.battery = bat
        if bat.status == "charging" or bat.status == "discharging" or bat.status == "full" then
            break
        end
    end

    for _, ac in pairs(self.units.ac) do
        self.ac = ac
        if ac.online then
            break
        end
    end
end

function power:update()
    for name, battery in pairs(self.units.bat) do
        local bat_status = file_utils.trim(file_utils.read("/sys/class/power_supply/" .. name .. "/status"))
        if bat_status ~= nil then
            battery.status = bat_status:lower()
        end

        local charge_now = file_utils.read("/sys/class/power_supply/" .. name .. "/charge_now")
        if charge_now == nil then
            charge_now = file_utils.read("/sys/class/power_supply/" .. name .. "/energy_now")
        end

        local charge_full = file_utils.read("/sys/class/power_supply/" .. name .. "/charge_full")
        if charge_full == nil then
            charge_full = file_utils.read("/sys/class/power_supply/" .. name .. "/energy_full")
        end

        if charge_now ~= nil and charge_full ~= nil then
            charge_now = file_utils.trim(charge_now)
            charge_full = file_utils.trim(charge_full)
            battery.charge_now = tonumber(charge_now) / tonumber(charge_full)
        end

        local voltage = file_utils.trim(file_utils.read("/sys/class/power_supply/" .. name .. "/voltage_now"))
        if voltage ~= nil then
            battery.voltage = tonumber(voltage)
        end
    end

    for name, ac in pairs(self.units.ac) do
        local online = file_utils.trim(file_utils.read("/sys/class/power_supply/" .. name .. "/online"))

        if online ~= nil and tonumber(online) ~= 0 then
            ac.online = true
        else
            ac.online = false
        end
    end

    signals.emit_signal("power::updated")
end

return power
