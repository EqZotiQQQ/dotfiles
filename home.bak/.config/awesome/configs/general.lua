local terminal = "kitty"
local editor = os.getenv("EDITOR") or "neovim"
local editor_cmd = terminal .. " -e " .. editor
local modkey = "Mod4"

local general = {
    terminal   = terminal,
    editor     = editor,
    editor_cmd = editor_cmd,
    modkey     = modkey
}

local menubar = require("menubar")
menubar.utils.terminal = general.terminal
awesome.set_preferred_icon_size(512)
return general