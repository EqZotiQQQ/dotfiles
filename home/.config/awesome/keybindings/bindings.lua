local awful = require("awful")
local menubar = require("menubar")
local gears = require("gears")

local modkey = require("configs.config_defaults").modkey
local terminal = require("configs.config_defaults").terminal
local panel_size = require("configs.panel").panel_size
local awesome_common = require("common.awesome_common")
local hotkeys_popup = require("awful.hotkeys_popup")
local volume_bindings = require("keybindings.volume_widget_bindings")

local client = _G.client

local ctrl = "Control"
local shift = "Shift"
local screenshot_path = "~/Pictures/Screenshots/"

local set_general_keyboard_bindings = function (mymainmenu)
    local bindings = gears.table.join(
        awful.key({ modkey, }, "s",       hotkeys_popup.show_help,                                 {description = "show help", group="awesome"}),
        awful.key({ modkey, }, "Left",    awful.tag.viewprev,                                      {description = "view previous", group = "tag"}),
        awful.key({ modkey, }, "Right",   awful.tag.viewnext,                                      {description = "view next", group = "tag"}),
        awful.key({ modkey, }, "Escape",  awful.tag.history.restore,                               {description = "go back", group = "tag"}),
        awful.key({ modkey, }, "j",       function () awful.client.focus.byidx( 1)end,             {description = "focus next by index", group = "client"}),
        awful.key({ modkey, }, "k",       function () awful.client.focus.byidx(-1)end,             {description = "focus previous by index", group = "client"}),
        awful.key({ modkey, }, "w",       function () mymainmenu:show() end,                       {description = "show main menu", group = "awesome"}),
        awful.key({ modkey, }, "l", function()   awful.spawn.easy_async_with_shell("lock.sh") end, {description = "lockscreen", group = "awesome"}),

        -- Layout manipulation
        awful.key({ modkey, shift }, "j", function () awful.client.swap.byidx(  1)    end,      {description = "swap with next client by index", group = "client"}),
        awful.key({ modkey, shift }, "k", function () awful.client.swap.byidx( -1)    end,      {description = "swap with previous client by index", group = "client"}),
        awful.key({ modkey, ctrl  }, "j", function () awful.screen.focus_relative( 1) end,      {description = "focus the next screen", group = "screen"}),
        awful.key({ modkey, ctrl  }, "k", function () awful.screen.focus_relative(-1) end,      {description = "focus the previous screen", group = "screen"}),
        awful.key({ modkey,       }, "u", awful.client.urgent.jumpto,                           {description = "jump to urgent client", group = "client"}),
        awful.key({ modkey,       }, "Tab",
            function()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            {description = "go back", group = "client"}),

        -- Standard program
        awful.key({ modkey,       }, "Return", function () awful.spawn(terminal)              end,{description = "open a terminal", group = "launcher"}),
        awful.key({ modkey, ctrl  }, "r",     awesome_common.restart,                             {description = "reload awesome", group = "awesome"}),
        awful.key({ modkey, shift }, "q",     awesome_common.quit,                                {description = "quit awesome", group = "awesome"}),
        awful.key({ modkey, shift }, "s",     awesome_common.suspend,                             {description = "suspend system. Doesn't logout!", group = "awesome"}),
        awful.key({ modkey,       }, "l",     function () awful.tag.incmwfact( 0.05)          end,{description = "increase master width factor", group = "layout"}),
        awful.key({ modkey,       }, "h",     function () awful.tag.incmwfact(-0.05)          end,{description = "decrease master width factor", group = "layout"}),
        awful.key({ modkey, shift }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,{description = "increase the number of master clients", group = "layout"}),
        awful.key({ modkey, shift }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,{description = "decrease the number of master clients", group = "layout"}),
        awful.key({ modkey, ctrl  }, "h",     function () awful.tag.incncol( 1, nil, true)    end,{description = "increase the number of columns", group = "layout"}),
        awful.key({ modkey, ctrl  }, "l",     function () awful.tag.incncol(-1, nil, true)    end,{description = "decrease the number of columns", group = "layout"}),
        awful.key({ modkey,       }, "space", function () awful.layout.inc( 1)                end,{description = "select next", group = "layout"}),
        awful.key({ modkey, shift }, "space", function () awful.layout.inc(-1)                end,{description = "select previous", group = "layout"}),

        awful.key({ modkey, ctrl }, "n",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", {raise = true}
                )
                end
            end,
            {description = "restore minimized", group = "client"}),

        -- Prompt
        awful.key({ modkey  }, "r", function()   awful.spawn("rofi -modi drun,run -show run -location 1 -xoffset " .. panel_size) end, {description = "run rofi launcher", group = "launcher"}),

        -- ScreenShots
        awful.key({              }, "Print",     function()      awful.spawn.with_shell("flameshot screen --clipboard")                         end, {description = "Take a screenshot of focused screen",  group = "media" }),
        awful.key({ ctrl         }, "Print",     function()      awful.spawn.with_shell("flameshot screen --path "..screenshot_path)      end, {description = "Interactive screenshot",               group = "media" }),
        awful.key({ modkey       }, "Print",     function()      awful.spawn.with_shell("flameshot gui")                                        end, {description = "Interactive screenshot to clipboard",  group = "media" }),
        awful.key({ "Mod1"       }, "Print",     function()      awful.spawn.with_shell("flameshot full --path "..screenshot_path)        end, {description = "Take a screenshot of all screens to file",  group = "media" }),
        awful.key({ "Mod1", ctrl }, "Print",     function()      awful.spawn.with_shell("flameshot full --clipboard")                           end, {description = "Take a screenshot of all screens to clipboard",  group = "media" })

        -- -- Audio Control
        -- awful.key({ modkey }, "]", function() volume_widget:inc(5)   end, {description = "Increase sound by 5 percent",  group = "media" }),
        -- awful.key({ modkey }, "[", function() volume_widget:dec(5)   end, {description = "Decrease sound by 5 percent",  group = "media" }),
        -- awful.key({ modkey }, "\\",function() volume_widget:toggle() end, {description = "Mute out sound",               group = "media" })
    )

    -- local volume_bindigns = volume_bindings(volume_widget)

    bindings = gears.table.join(
        bindings
        -- volume_bindigns
)
    return bindings
end

return set_general_keyboard_bindings