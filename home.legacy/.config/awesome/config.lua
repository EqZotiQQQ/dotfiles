-- This module stores system-wide configuration for applications and preferences.

local config = {}

-- Default terminal emulator
config.terminal = os.getenv("TERM") or "terminator"

-- Default editor (used in prompts, spawn, etc.)
config.editor = os.getenv("EDITOR") or "nvim"

-- GUI editor for graphical use
config.gui_editor = "code" -- VS Code, change as needed

-- Default web browser
config.browser = "firefox"

-- Default file manager
config.file_manager = "nautilus"

-- Modifier key (Mod4 is usually the Super/Windows key)
config.modkey = "Mod4"

-- Launcher (e.g. rofi, dmenu)
config.launcher = "rofi -show drun"

-- Screenshot tool
config.screenshot = "flameshot gui"

-- Lock screen command
config.lockscreen = "i3lock"

-- Default layout (optional)
config.default_layout = "tile"

-- Debug mode enabled
config.debug = true

return config
