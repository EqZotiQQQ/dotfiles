local d = require("dbg")

local beautiful = require("beautiful")

local default_theme = require("theme.default")
local improved_theme = require("theme.improved_default")

local final_theme = {}
local gtable = require('gears.table')

gtable.crush(final_theme, default_theme.theme)
gtable.crush(final_theme, improved_theme.theme)

default_theme.awesome_overrides(final_theme)
improved_theme.awesome_overrides(final_theme)

beautiful.init(final_theme)