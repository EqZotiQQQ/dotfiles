local gtable = require('gears.table')
local default_theme = require("theme_management.default")

local improved_theme = require("theme_management.improved_default")

local final_theme = {}
gtable.crush(final_theme, default_theme.theme)
gtable.crush(final_theme, improved_theme.theme)
default_theme.awesome_overrides(final_theme)
improved_theme.awesome_overrides(final_theme)

return final_theme
