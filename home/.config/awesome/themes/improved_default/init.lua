---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local filesystem = require('gears.filesystem')
local theme_dir = filesystem.get_configuration_dir() .. '/themes/'

local high_level_theme_config = require("configs.theme")

local theme = {}


local font_family = {
    iosevka = "Iosevka",
}

local font = font_family.iosevka.." 12"
local taglist_font_size = 15
local taglist_font = font_family.iosevka.." "..taglist_font_size


local awesome_overrides = function(theme)
    theme.font          = font

    theme.bg_normal     = "#222222"
    theme.bg_focus      = "#535d6c"
    theme.bg_urgent     = "#ff0000"
    theme.bg_minimize   = "#444444"
    theme.bg_systray    = theme.bg_normal

    theme.fg_normal     = "#FFD700"
    theme.fg_focus      = "#ffffff"
    theme.fg_urgent     = "#ffffff"
    theme.fg_minimize   = "#ffffff"

    theme.taglist_font  = taglist_font

    theme.useless_gap   = dpi(0)
    theme.border_width  = dpi(1)
    theme.border_normal = "#000000"
    theme.border_focus  = "#535d6c"
    theme.border_marked = "#91231c"

    theme.menu_submenu_icon = theme_dir.."improved_default/submenu.png"
    theme.menu_height = dpi(40)
    theme.menu_width  = dpi(300)

    theme.titlebar_close_button_normal = theme_dir.."default/titlebar/close_normal.png"
    theme.titlebar_close_button_focus  = theme_dir.."default/titlebar/close_focus.png"

    theme.titlebar_minimize_button_normal = theme_dir.."default/titlebar/minimize_normal.png"
    theme.titlebar_minimize_button_focus  = theme_dir.."default/titlebar/minimize_focus.png"

    theme.titlebar_ontop_button_normal_inactive = theme_dir.."default/titlebar/ontop_normal_inactive.png"
    theme.titlebar_ontop_button_focus_inactive  = theme_dir.."default/titlebar/ontop_focus_inactive.png"
    theme.titlebar_ontop_button_normal_active = theme_dir.."default/titlebar/ontop_normal_active.png"
    theme.titlebar_ontop_button_focus_active  = theme_dir.."default/titlebar/ontop_focus_active.png"

    theme.titlebar_sticky_button_normal_inactive = theme_dir.."default/titlebar/sticky_normal_inactive.png"
    theme.titlebar_sticky_button_focus_inactive  = theme_dir.."default/titlebar/sticky_focus_inactive.png"
    theme.titlebar_sticky_button_normal_active = theme_dir.."default/titlebar/sticky_normal_active.png"
    theme.titlebar_sticky_button_focus_active  = theme_dir.."default/titlebar/sticky_focus_active.png"

    theme.titlebar_floating_button_normal_inactive = theme_dir.."default/titlebar/floating_normal_inactive.png"
    theme.titlebar_floating_button_focus_inactive  = theme_dir.."default/titlebar/floating_focus_inactive.png"
    theme.titlebar_floating_button_normal_active = theme_dir.."default/titlebar/floating_normal_active.png"
    theme.titlebar_floating_button_focus_active  = theme_dir.."default/titlebar/floating_focus_active.png"

    theme.titlebar_maximized_button_normal_inactive = theme_dir.."default/titlebar/maximized_normal_inactive.png"
    theme.titlebar_maximized_button_focus_inactive  = theme_dir.."default/titlebar/maximized_focus_inactive.png"
    theme.titlebar_maximized_button_normal_active = theme_dir.."default/titlebar/maximized_normal_active.png"
    theme.titlebar_maximized_button_focus_active  = theme_dir.."default/titlebar/maximized_focus_active.png"

    theme.wallpaper = high_level_theme_config.wallpaper.blue_colored_cosy_willage

    -- You can use your own layout icons like this:
    theme.layout_fairh = theme_dir.."default/layouts/fairhw.png"
    theme.layout_max = theme_dir.."default/layouts/maxw.png"
    theme.layout_tile = theme_dir.."default/layouts/tilew.png"

    -- Generate Awesome icon:
    theme.awesome_icon = theme_assets.awesome_icon(
        theme.menu_height, theme.bg_focus, theme.fg_focus
    )

    theme.menu = {}
    theme.menu.turn_off = theme_dir.."improved_default/icons/turn-off.png"

    -- Define the icon theme for application icons. If not set then the icons
    -- from /usr/share/icons and /usr/share/icons/hicolor will be used.
    theme.icon_theme = nil
end

return {
	theme = theme,
 	awesome_overrides = awesome_overrides
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
