-- Shared theme for hyprland.lua: ~/.config/theme/theme.json.
-- The same file is read by the Quickshell bar (live) and by `lock`; keys: ~/.config/theme/README.md
local json = require("lib.json")

local dir  = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local path = dir .. "/theme/theme.json"

local f = assert(io.open(path, "r"), "theme: cannot open " .. path)
local theme = json.decode(f:read("a"))
f:close()

-- "#rrggbb" + alpha 0..1 -> "rgba(rrggbbaa)", the Hyprland color format
function theme.rgba(hex, alpha)
    return string.format("rgba(%s%02x)", hex:sub(2):lower(), math.floor((alpha or 1) * 255 + 0.5))
end

return theme
