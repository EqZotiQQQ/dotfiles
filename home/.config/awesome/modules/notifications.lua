---@diagnostic disable: unused-local
local d = require("dbg")
local gears = require('gears')
local wibox = require('wibox')
local awful = require('awful')
local ruled = require('ruled')
local naughty = require('naughty')
local menubar = require('menubar')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require('widget.clickable-container')

-- Defaults
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.margin = dpi(16)
naughty.config.defaults.border_width = 0
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, dpi(6))
end

-- Apply theme variables
naughty.config.padding = dpi(8)
naughty.config.spacing = dpi(8)
naughty.config.icon_dirs = {
	'/usr/share/icons/Tela',
	'/usr/share/icons/Tela-blue-dark',
	'/usr/share/icons/Papirus/',
	'/usr/share/icons/la-capitaine-icon-theme/',
	'/usr/share/icons/gnome/',
	'/usr/share/icons/hicolor/',
	'/usr/share/pixmaps/'
}
naughty.config.icon_formats = { 'svg', 'png', 'jpg', 'gif' }

-- Presets / rules

-- ruled.notification.connect_signal(
-- 	'request::rules',
-- 	function()

-- 		-- Critical notifs
-- 		ruled.notification.append_rule {
-- 			rule       = { urgency = 'critical' },
-- 			properties = { 
-- 				font        		= 'Inter Bold 10',
-- 				bg 					= '#ff0000', 
-- 				fg 					= '#ffffff',
-- 				margin 				= dpi(16),
-- 				position 			= 'top_right',
-- 				implicit_timeout	= 0
-- 			}
-- 		}

-- 		-- Normal notifs
-- 		ruled.notification.append_rule {
-- 			rule       = { urgency = 'normal' },
-- 			properties = {
-- 				font        		= 'Inter Regular 10',
-- 				bg      			= beautiful.transparent, 
-- 				fg 					= beautiful.fg_normal,
-- 				margin 				= dpi(16),
-- 				position 			= 'top_right',
-- 				implicit_timeout 	= 5
-- 			}
-- 		}

-- 		-- Low notifs
-- 		ruled.notification.append_rule {
-- 			rule       = { urgency = 'low' },
-- 			properties = { 
-- 				font        		= 'Inter Regular 10',
-- 				bg     				= beautiful.transparent,
-- 				fg 					= beautiful.fg_normal,
-- 				margin 				= dpi(16),
-- 				position 			= 'top_right',
-- 				implicit_timeout	= 5
-- 			}
-- 		}
-- 	end
-- 	)

-- -- Error handling
-- naughty.connect_signal(
-- 	'request::display_error',
-- 	function(message, startup)
-- 		naughty.notification {
-- 			urgency = 'critical',
-- 			title   = 'Oops, an error happened'..(startup and ' during startup!' or '!'),
-- 			message = message,
-- 			app_name = 'System Notification',
-- 			icon = beautiful.awesome_icon
-- 		}
-- 	end
-- )

-- -- XDG icon lookup
-- naughty.connect_signal(
-- 	'request::icon',
-- 	function(n, context, hints)
-- 		if context ~= 'app_icon' then return end

-- 		local path = menubar.utils.lookup_icon(hints.app_icon) or
-- 		menubar.utils.lookup_icon(hints.app_icon:lower())

-- 		if path then
-- 			n.icon = path
-- 		end
-- 	end
-- )
