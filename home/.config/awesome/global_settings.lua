-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.


local dpi = require("beautiful.xresources").apply_dpi

local position = {
    top = "top",
    bottom = "bottom",
    left = "left",
    right = "right",
}

local global = {
    terminal        = "kitty",
    modkey          = "Mod4",
    file_explorer   = "nautilus",
    panel_size      = dpi(50),
    panel_position  = position.top,
    theme_dir       = "~/.config/awesome/themes/default", -- "~/.config/awesome/themes/xresources"
    editor          = os.getenv("EDITOR") or "neovim",
    dynamic_theme   = false,
    wallpaper       = "~/Pictures/1.jpg",
}

global.editor_cmd   = global.terminal .. " -e " .. global.editor

return global

-- shift       Shift_L (0x32),  Shift_R (0x3e)
-- lock        Caps_Lock (0x42)
-- control     Control_L (0x25),  Control_R (0x69)
-- mod1        Alt_L (0x40),  Meta_L (0xcd)
-- mod2        Num_Lock (0x94)
-- mod3      
-- mod4        Super_R (0x86),  Super_L (0xce),  Hyper_L (0xcf)
-- mod5        ISO_Level3_Shift (0x5c),  ISO_Level3_Shift (0x6c),  Mode_switch (0x85),  Mode_switch (0xcb)
