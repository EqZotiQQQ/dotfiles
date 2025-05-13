local cpu_module = require("system.cpu")
local ram_module = require("system.ram")
local temperature_module = require("system.temperature")
local net_module = require("system.net")

local system_watchdogs = {}


function system_watchdogs.init_system_monitors()
    local cpu_monitor = cpu_module:new()
    cpu_monitor:register_timer(1)

    local ram_monitor = ram_module:new()
    ram_monitor:register_timer(1)


    local temperature_monitor = temperature_module:new()
    temperature_monitor:register_timer(1)

    local net_monitor = net_module:new()
    net_monitor:register_timer(1)

    return {
        cpu_monitor = cpu_monitor,
        ram_monitor = ram_monitor,
        temperature_monitor = temperature_monitor,
        net_monitor = net_monitor,
    }
end

return system_watchdogs
