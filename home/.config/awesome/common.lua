
local d = require("dbg")
local gears = require("gears")
local beautiful = require("beautiful")

local common = {
    set_wallpaper = function(current_screen)
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(current_screen)
            end
            gears.wallpaper.maximized(wallpaper, current_screen, true)
        end
    end
}

return common