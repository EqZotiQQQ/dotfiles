---------------------------------------------------------------------------
--- Rules
--
-- Awesome tag settings
-- https://awesomewm.org/doc/api/libraries/awful.rules.html
---------------------------------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local keybindings = require("keybindings")

local screen = _G.screen


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
local rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keybindings.keyboard.client,
            buttons = keybindings.mouse.client,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer"
            },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        }, properties = { floating = true }
    },

-- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = {
                "normal",
                "dialog"
            }
        },
        properties = { titlebars_enabled = true }
    },

    {
        rule_any = {
            class = {
                "TelegramDesktop",
            }
        },
        properties = {
            screen = screen.count()>1 and 2 or 1,
            tag = screen.count()>1 and "1" or "2"
        }
    },
    {
        rule_any = {
            class = {"discord"}
        },
        properties = {
            screen = screen.count()>1 and 2 or 1,
            tag = screen.count()>1 and "3" or "4"
        },
    },
    {
        rule_any = {
            class = {
                "mattermost-desktop",
                "Mattermost",
                "Mattermost Desktop App",
            }
        },
        properties = {
            screen = screen.count()>1 and 2 or 1,
            tag = screen.count()>1 and "3" or "4"
        },
    },
}

return rules
