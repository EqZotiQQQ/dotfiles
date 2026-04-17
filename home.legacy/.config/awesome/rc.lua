local config = require("config")
local awful = require("awful")
local debug = require("dbg")

local theme = require("themes")
theme.init_module()
theme.init_signals()

local layout = require("layout")
layout.init_signals()

local tags = require("tags")
tags.init_signals()

local widgets = require("widgets")
widgets.init_taskbar_widgets()

local bindings = require("keys")
bindings.init_glob_bindings()

local sys_monitor = require("system")
sys_monitor.init_system_monitors()

debug.stdout("done")
