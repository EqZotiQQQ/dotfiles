-- theme/init.lua
-- Loads the visual theme using beautiful

local beautiful = require("beautiful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local debug = require("dbg")
local config = require("config")

local theme = require("themes.default.theme")

local theme_obj = {}

function theme_obj.init_module()
    -- Path to your theme (change if needed)
    beautiful.init(theme)

    -- local wallpapper_path = gears.filesystem.get_themes_dir() .. "/default/background.png"
    -- Optional: apply DPI
    -- local xresources = require("beautiful.xresources")
    -- beautiful.xresources.set_dpi(xresources.get_dpi())
end

function theme_obj.init_signals()
    screen.connect_signal(
        "request::wallpaper",
        function(s)
            if config.debug then
                debug.log("screen connected with config:")
                debug.log(s)
            end
            gears.wallpaper.set(theme.solid_wallpapper_color)
        end
    )
end

return theme_obj
