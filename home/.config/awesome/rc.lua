-- local awful = require("awful")

local config = require("config")
local awful = require("awful")
local debug = require("dbg")

debug.stdout(config)

local theme = require("themes")
theme.init_module()
theme.init_signals()

local layout = require("layout")
layout.init_signals()

local tags = require("tags")
tags.init_signals()

local widgets = require("widgets")
widgets.init_panel()

debug.stdout("done")
