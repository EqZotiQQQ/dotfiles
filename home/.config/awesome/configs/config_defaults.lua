local terminal = "kitty"
local editor = os.getenv("EDITOR") or "neovim"
local editor_cmd = terminal .. " -e " .. editor
local modkey = "Mod4"

local config_defaults = {
    terminal   = terminal,
    editor     = editor,
    editor_cmd = editor_cmd,
    modkey     = modkey
}

return config_defaults