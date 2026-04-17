local awful = require("awful")
local wibox = require("wibox")
local theme = require("themes.default.theme")


local tags = {}

local screen_tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

function tags.init_signals()
    screen.connect_signal(
        "request::desktop_decoration",
        function(screen)
            -- Each screen has its own tag table.
            awful.tag(screen_tags, screen, awful.layout.layouts[1])
        end
    )
end

return tags
