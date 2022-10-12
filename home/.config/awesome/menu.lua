---------------------------------------------------------------------------
--- Menu
--
-- Create a launcher widget and a main menu
-- @module menu
---------------------------------------------------------------------------

local awesome = _G.awesome

local awful = require("awful")

local hotkeys_popup = require("awful.hotkeys_popup")

-- This is used later as the default terminal and editor to run.
local terminal = "kitty"
local editor = os.getenv("EDITOR") or "editor"
local editor_cmd = terminal .. " -e " .. editor

local myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
 }

 return myawesomemenu