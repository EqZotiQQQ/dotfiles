local home = os.getenv("HOME")
local theme_base_path = home.."/.config/awesome/theme_management"


local themes = {
    default = theme_base_path.."/default/theme.lua",
    improved_default = theme_base_path.."/improved_default/theme.lua",
}

local wallpapers = {
    blue_colored_cosy_willage = home.."/Pictures/blue_black_gradient.jpg"
}

local high_level_theme_config = {
    theme = themes.improved_default,
    wallpaper = wallpapers,
}

return high_level_theme_config
