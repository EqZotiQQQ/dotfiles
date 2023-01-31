local wibox = require("wibox")
local beautiful = require('beautiful')

local panel_size = require("configs.panel").panel_size

local audio = require("widgets.screen.cava.details.audio")


local get_script_location = require("common.awesome_common").get_script_location
local d = require("dbg")
local ICON_DIR = get_script_location() .. '../'.. 'icons/'

local widget = {}

function widget.get_widget(widgets_args)
    local args = widgets_args or {}

    local thickness = args.thickness or 2
    local main_color = args.main_color or beautiful.fg_color
    local bg_color = args.r or '#ffffff11'
    local mute_color = args.mute_color or beautiful.fg_urgent
    local size = args.size or panel_size - 10

    return wibox.widget {
        {
            id = "icon",
            image = ICON_DIR .. 'audio-volume-high-symbolic.svg',
            resize = true,
            widget = wibox.widget.imagebox,
        },
        max_value = 100,
        thickness = thickness,
        start_angle = 4.71238898, -- 2pi*3/4
        forced_height = size,
        forced_width = size,
        bg = bg_color,
        paddings = 2,
        widget = wibox.container.arcchart,
        set_volume_level = function(self, new_value)
            self.value = new_value
        end,
        mute = function(self)
            self.colors = { mute_color }
        end,
        unmute = function(self)
            self.colors = { main_color }
        end
    }
end

return widget