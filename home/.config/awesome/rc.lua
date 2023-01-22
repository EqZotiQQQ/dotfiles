-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
-- pcall(require, "luarocks.loader")

local general_config = require("general_config")
local theme_config = require("theme_config")

-- glob variables
local awesome = _G.awesome
local root = _G.root

local d = require("dbg")

local terminal = general_config.terminal

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(theme_config.theme_dir .. "/theme.lua")

awesome.set_preferred_icon_size(64)
local naughty = require("naughty")
local awful = require("awful")

require("awful.autofocus")
local signals = require("signals")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Configure keybindings
local bindings = require("keybindings")
root.buttons(bindings.mouse.global)
root.keys(bindings.keyboard.global)
-- }}

-- {{{ Configure rules
local rules = require("rules")
awful.rules.rules = rules
-- }}}

-- {{{ Configure error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end
signals.on_error_signal()
-- }}}


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}
-- }}}

-- Menubar configuration
local menubar = require("menubar")
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Configure screens
local connect_for_each_screen = require("screen")
connect_for_each_screen()
-- }}}

-- {{{ Configure signals
for func_name, func in pairs(signals) do
    if func_name ~= "on_error_signal" then
        func()
    end
end
-- }}}

-- {{{ Autostart apps
require("autostart")
-- }}}