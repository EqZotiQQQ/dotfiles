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

local awful = require("awful")

require("awful.autofocus")

local menubar = require("menubar")


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
local error_handling = require("error_handling")
error_handling.startup_error_check()
error_handling.add_runtime_error_check_signal()
-- }}}


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Configure screens
require("screen")
-- }}}

-- {{{ Configure signals
require("signals")
-- }}}

-- {{{ Autostart apps
require("autostart")
-- }}}