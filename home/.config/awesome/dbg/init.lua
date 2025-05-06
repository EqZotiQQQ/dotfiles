-- debug/init.lua
-- Simple logging/debugging utility for AwesomeWM

local M = {}

-- Print message with optional tag
function M.screen_out(msg, tag)
    local prefix = "[DEBUG]"
    if tag then
        prefix = "[" .. tag .. "]"
    end
    print(prefix .. " " .. tostring(msg))
end

-- Dump contents of a table (recursively, with optional depth)
function M.stdout(tbl, indent)
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
            M.dump(v, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. key .. " = " .. tostring(v))
        end
    end
end

M.log = M.stdout

return M
