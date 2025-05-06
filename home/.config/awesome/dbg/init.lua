-- debug/init.lua
-- Simple logging/debugging utility for AwesomeWM
local wibox = require("wibox")

local dbg_module = {}

-- Print message with optional tag
function dbg_module.screen_out(msg, tag)
    local prefix = "[DEBUG]"
    if tag then
        prefix = "[" .. tag .. "]"
    end
    print(prefix .. " " .. tostring(msg))
end

-- Dump contents of a table (recursively, with optional depth)
function dbg_module.stdout(tbl, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)

    if type(tbl) ~= "table" then
        print(spacing .. tostring(tbl))
        return
    end

    for k, v in pairs(tbl) do
        local key = tostring(k)
        if type(v) == "table" then
            print(spacing .. key .. " = {")
            dbg_module.dump(v, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. key .. " = " .. tostring(v))
        end
    end
end

dbg_module.log = dbg_module.stdout

function dbg_module.wrap_widget(widget)
    local highlighted_widget = wibox.container.margin(
        wibox.container.background(widget, "purple"),
        2, 2, 2, 2 -- left, right, top, bottom (ширина рамки)
    )
    return highlighted_widget
end

return dbg_module
