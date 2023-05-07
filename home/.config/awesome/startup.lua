-- StartUp apps
-- awful.spawn.with_shell("app --some-flags")

local awful = require("awful")

local d = require("dbg")

local hour = os.date("*t").hour
local wday = os.date("*t").wday

local functions = {}

-- awful.spawn.once("xrandr --output DP-0 --primary --mode 2560x1440 -r 144 --pos 0x0 --rotate normal --output DP-2 --mode 1920x1080 --rotate normal -r 60 --pos 2560x0")

functions.work_tools = function()
    if (hour > 9 and hour < 18) and wday < 6 then
        awful.spawn.once("mattermost-desktop")
    end
end
functions.general_tools = function()
    if (hour < 9 and hour > 18) or wday > 6 then
        -- awful.spawn.once("discord")
    end
end
functions.run_always = function ()
    -- awful.spawn.once("telegram-desktop")
    awful.spawn.once("flameshot")
    awful.spawn.once("picom")

    -- Keyboard layout
    awful.spawn.spawn("setxkbmap -layout us,ru, -option 'grp:ctrl_shift_toggle'")
end

return functions
