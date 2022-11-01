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

local global = require("global_settings")

local hotkeys_popup = require("awful.hotkeys_popup")

-- This is used later as the default terminal and editor to run.
local terminal = global.terminal
local editor_cmd = global.editor_cmd
local file_explorer = global.file_explorer

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
    { "Visual Studio Code", function() awful.spawn("code") end },
    { "PyCharm", function() awful.spawn("pycharm-community") end },
    { "CLion", function() awful.spawn("clion") end }
}

local productive = {
    { "Notion", function() awful.spawn("notion-snap") end }
}

local messaging = {
    {"Discord", function() awful.spawn("discord") end },
    {"MatterMost", function() awful.spawn("mattermost-desktop") end },
    {"Telegram", function() awful.spawn("telegram-desktop") end },
}

local internet = {
    {"Google Chrome",  function() awful.spawn("google-chrome") end },
    {"Firefox",        function() awful.spawn("firefox") end }
}

local menu = { 
    main = awful.menu({
        items = {
            {"Power",       menu_power},
            {"Awesome",     awesomewm_menu},
            {"Internet",    internet},
            {"IDE",         ides},
            {"Messaging",   messaging},
            {"Productive",  productive},
            {"Nautilus",    file_explorer},
            {"Terminal",    terminal}
        }
    })
}

return menu
