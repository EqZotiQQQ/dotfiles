local _, freedesktop = pcall(require, "freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
local general = require("configs.general")
local awesome_common = require("common.awesome_common")
local awful = require("awful")
local beautiful = require("beautiful")

-- Awesome stack
local awesome = _G.awesome

local myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", general.terminal .. " -e man awesome" },
    { "edit config", general.editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome_common.restart },
    { 'log out', awesome_common.log_out },
    { 'suspend', awesome_common.suspend },
    { "quit", awesome_common.quit },
    { 'power off', awesome_common.power_off },
 }
local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", general.terminal }

local menu = freedesktop.menu.build({
    before = { menu_awesome },
    after =  { menu_terminal }
})

return menu