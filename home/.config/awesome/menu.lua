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

-- Load Debian menu entries
local debian = require("debian.menu")

-- Theme handling library
local beautiful = require("beautiful")

local hotkeys_popup = require("awful.hotkeys_popup")

local has_fdo, freedesktop = pcall(require, "freedesktop")

-- This is used later as the default terminal and editor to run.
local terminal = _G.terminal
local modkey = _G.modkey
local editor_cmd = _G.editor_cmd

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

local menu = {}
menu.main = awful.menu({
    items = {
        {"Power",    menu_power},
        {"Awesome",  awesomewm_menu},
        {"Terminal", terminal}
    }
})


-- local menu_awesome = {
--     "awesome",
--     myawesomemenu,
--     beautiful.awesome_icon
-- }
-- local menu_terminal = {
--     "open terminal",
--     terminal
-- }

-- if has_fdo then
--     return freedesktop.menu.build({
--         before = { menu_awesome },
--         after =  { menu_terminal }
--     })
-- else
--     return awful.menu({
--         items = {
--             menu_awesome,
--             {
--                 "Debian",
--                 debian.menu.Debian_menu.Debian
--             },
--             menu_terminal,
--         }
--     })
-- end

-- local mylauncher = awful.widget.launcher({
--     image = beautiful.awesome_icon,
--     menu = mymainmenu
-- })

return menu
