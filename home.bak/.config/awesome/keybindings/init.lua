local gears = require("gears")
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

root.buttons(mouse_bindings)
root.keys(keyboard_bindings)
