local beautiful = require("beautiful")
local gears = require("gears")

local functions = {}

functions.set_wallpaper = function(this_screen)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(this_screen)
        end
        gears.wallpaper.maximized(wallpaper, this_screen, true)
    end
end

return functions