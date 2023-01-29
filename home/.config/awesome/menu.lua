local _, freedesktop = pcall(require, "freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
local config_defaults = require("configs.config_defaults")
local awesome_common = require("common.awesome_common")
local awful = require("awful")
local beautiful = require("beautiful")

-- Awesome stack
local awesome = _G.awesome

local myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", config_defaults.terminal .. " -e man awesome" },
    { "edit config", config_defaults.editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome_common.restart },
    { "quit", awesome_common.quit },
 }
local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", config_defaults.terminal }

local mymainmenu = freedesktop.menu.build({
    before = { menu_awesome },
    after =  { menu_terminal }
})

return mymainmenu