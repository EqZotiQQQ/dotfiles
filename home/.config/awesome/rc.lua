-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
-- pcall(require, "luarocks.loader")

local globals = require("global_settings")

-- glob variables
local awesome = _G.awesome

local terminal = globals.terminal

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(globals.theme_dir .. "/theme.lua")

awesome.set_preferred_icon_size(64)

local awful = require("awful")

require("awful.autofocus")

local menubar = require("menubar")

local d = require("cosy.dbg")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Configure keybindings
require("keybindings")
-- }}

-- {{{ Configure rules
require("rules")
-- }}}

-- {{{ Configure error handling
require("error_handling")
-- }}}


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
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