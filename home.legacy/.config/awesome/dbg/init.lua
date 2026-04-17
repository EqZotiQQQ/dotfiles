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
            dbg_module.stdout(v, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. key .. " = " .. tostring(v))
        end
    end
end

function dbg_module.stdout2(tbl, indent)
    if type(tbl) == "table" and next(tbl) ~= nil then
        if not indent then indent = 0 end
        local toprint = string.rep(" ", indent) .. "{\r\n"
        indent = indent + 2
        for k, v in pairs(tbl) do
            toprint = toprint .. string.rep(" ", indent)
            if (type(k) == "number") then
                toprint = toprint .. "[" .. k .. "] = "
            elseif (type(k) == "string") then
                toprint = toprint .. k .. "= "
            end
            if (type(v) == "number") then
                toprint = toprint .. v .. ",\r\n"
            elseif (type(v) == "string") then
                toprint = toprint .. "\"" .. v .. "\",\r\n"
            elseif (type(v) == "table") then
                toprint = toprint .. dbg_module.stdout2(v, indent + 2) .. ",\r\n"
            else
                toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
            end
        end
        toprint = toprint .. string.rep(" ", indent - 2) .. "}"
        return toprint
    else
        return nil
    end
end

dbg_module.log = dbg_module.stdout

function dbg_module.wrap_widget(widget, color)
    if color == nil then
        color = "red"
    end
    local highlighted_widget = wibox.container.background(widget)
    highlighted_widget.border_width = 1
    highlighted_widget.border_color = color
    highlighted_widget.bg = nil
    return highlighted_widget
end

dbg_module.w = dbg_module.wrap_widget

return dbg_module
