
local d = require("cosy.dbg")
local gears = require("gears")
local beautiful = require("beautiful")

local common = {
    set_wallpaper = function(current_screen)
        -- d.notify("set_wallpaper")
        -- Wallpaper
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(current_screen)
            end
            gears.wallpaper.maximized(wallpaper, current_screen, true)
        end
    end
}

return common