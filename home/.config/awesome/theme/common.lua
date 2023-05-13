local d = require("dbg")

local beautiful = require("beautiful")
local gears = require("gears")

local theme_config = require("configs.theme")


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

functions.get_theme = function()
    return theme_config.theme
end

return functions