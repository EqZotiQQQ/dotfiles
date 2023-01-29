local themes = {
    default = os.getenv("HOME").."/.config/awesome/theme_management/default/theme.lua",
    improved_default = os.getenv("HOME").."/.config/awesome/theme_management/improved_default/theme.lua",
}

local wallpapers = {
    blue_colored_cosy_willage = os.getenv("HOME").."/Pictures/1.jpg"
}

local high_level_theme_config = {
    theme = themes,
    wallpaper = wallpapers,
}

return high_level_theme_config