-- StartUp apps
-- awful.spawn.with_shell("app --some-flags")

local awful = require("awful")

local hour = os.date("*t").hour
local wday = os.date("*t").wday

local functions = {}

functions.work_tools = function()
    if (hour > 9 and hour < 18) and wday < 6 then
        awful.spawn.once("mattermost-desktop")
    end
end
functions.general_tools = function()
    if (hour < 9 and hour > 18) or wday > 6 then
        awful.spawn.once("discord")
    end
end
functions.run_always = function ()
    -- awful.spawn.once("telegram-desktop")
    awful.spawn.once("flameshot")
    -- awful.spawn.once("picom")

    -- Keyboard layout
    awful.spawn.spawn("setxkbmap -layout us,ru, -option 'grp:ctrl_shift_toggle'")
end

return functions
