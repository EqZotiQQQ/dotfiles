local d = require("dbg")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")

local beautiful = require("beautiful")
beautiful.init(require("theme"))

require("core.notifications")
local theme_utils = require("theme.utils")

local awesome = _G.awesome
local client = _G.client
local root = _G.root
local screen = _G.screen

require("system")
awesome.set_preferred_icon_size(512)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", theme_utils.set_wallpaper)

require("layout")

-- {{{ Bindings
local menu = require("menu")
local set_mouse_bindings = require("keybindings.mouse_bindings")
local mouse_bindings = set_mouse_bindings(menu)

local set_keyboard_bindings = require("keybindings.global")
local keyboard_bindings = set_keyboard_bindings(menu)

local add_tags_bindings = require("keybindings.panel_bindings")
keyboard_bindings = add_tags_bindings(keyboard_bindings)

local init_volume_widget_bindings = require("keybindings.volume_widget_bindings")
local volume_bindings = init_volume_widget_bindings()

keyboard_bindings = gears.table.join(
    volume_bindings,
    keyboard_bindings
)
-- Set keys
root.buttons(mouse_bindings)
root.keys(keyboard_bindings)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
require("core.rules")
-- }}}
require("core.signals")

local startups = require("startup")
for _, startup_item_init in pairs(startups) do
    startup_item_init()
end