---------------------------------------------------------------------------
--- Menu
--
-- Create a launcher widget and a main menu
-- @module menu
---------------------------------------------------------------------------

-- glob variables
local awesome = _G.awesome

-- Standard awesome library
local awful = require("awful")

local hotkeys_popup = require("awful.hotkeys_popup")

-- This is used later as the default terminal and editor to run.
local terminal = _G.terminal
local editor_cmd = _G.editor_cmd
local file_explorer = _G.file_explorer

local menu_power = {
    {"Power Off", "poweroff"},
    {"Reboot"   , "reboot"},
}

local awesomewm_menu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
}

local ides = {
    { "Visual Studio Code", function() awful.spawn.once("code") end },
    { "PyCharm", function() awful.spawn.once("pycharm-community") end },
    { "CLion", function() awful.spawn.once("clion") end }
}


local menu = { 
    main = awful.menu({
        items = {
            {"Power",    menu_power},
            {"Awesome",  awesomewm_menu},
            {"IDE",      ides},
            {"Nautilus", file_explorer},
            {"Terminal", terminal}
        }
    })
}

return menu
