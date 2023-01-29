---------------------------------------------------------------------------
--- Bindings
-- Keyboard bindings
--
-- @module bindings
---------------------------------------------------------------------------

require("awful.hotkeys_popup.keys")

local general_config = require("general_config")
local theme_config = require("theme_config")
local d = require("dbg")
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local gears = require("gears")
local menu = require("menu")
local beautiful = require("beautiful")

local volume_widget = require("widgets.volume-widget.volume")

local panel_config = require("panel_config")

local client = _G.client
local awesome = _G.awesome
local screen = _G.screen

local modkey = general_config.modkey
local theme_dir = theme_config.theme_dir
local terminal = general_config.terminal

local high_level_theme_config = require("configs.theme")

local screenshot_path = "~/Pictures/Screenshots/"

local shift = "Shift"
local ctrl = "Control"

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({
                heme = {
                    width = 250
                }
            })
        end
    end
end

local function reload_color()
    beautiful.init(high_level_theme_config.theme)
    for s in screen do
        _G.cosy_init_screen(s)
    end
end

-- {{{ Key bindings

local bindings = {
    modkey = modkey,
}

bindings.mouse = {
    client = gears.table.join(
        awful.button({ }, 1,
            function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
            end
        ),  awful.button({ modkey }, 1,
            function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.move(c)
            end
        ),
        awful.button({ modkey }, 3,
            function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.resize(c)
            end
        )
    ),
    global = gears.table.join(
        awful.button({ }, 3, function () menu.main:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    )
}

bindings.keyboard = {
    global = gears.table.join(
        awful.key({ modkey, }, "s",       hotkeys_popup.show_help,                      {description = "show help",                 group="awesome"     }),
        awful.key({ modkey, }, "Left",    awful.tag.viewprev,                           {description = "view previous",             group = "tag"       }),
        awful.key({ modkey, }, "Right",   awful.tag.viewnext,                           {description = "view next",                 group = "tag"       }),
        awful.key({ modkey, }, "Escape",  awful.tag.history.restore,                    {description = "go back",                   group = "tag"       }),
        awful.key({ modkey, }, "j",       function () awful.client.focus.byidx( 1) end, {description = "focus next by index",       group = "client"    }),
        awful.key({ modkey, }, "k",       function () awful.client.focus.byidx(-1) end, {description = "focus previous by index",   group = "client"    }),
        awful.key({ modkey, }, "/",       reload_color,                                 {description = "reload awesome colors",     group = "awesome"   }),

        -- Layout manipulation
        awful.key({ modkey, shift }, "j",       function () awful.client.swap.byidx(  1)    end, {description = "swap with next client by index",       group = "client"    }),
        awful.key({ modkey, shift }, "k",       function () awful.client.swap.byidx( -1)    end, {description = "swap with previous client by index",   group = "client"    }),
        awful.key({ modkey, ctrl  }, "j",       function () awful.screen.focus_relative( 1) end, {description = "focus the next screen",                group = "screen"    }),
        awful.key({ modkey, ctrl  }, "k",       function () awful.screen.focus_relative(-1) end, {description = "focus the previous screen",            group = "screen"    }),
        awful.key({ modkey,       }, "u",       awful.client.urgent.jumpto,                      {description = "jump to urgent client",                group = "client"    }),
        awful.key({ modkey,       }, "Tab",
            function () 
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            {description = "go back", group = "client"}),

        -- Standard program 
        awful.key({ modkey,       }, "Return",  function () awful.spawn(terminal)               end, {  description = "open a terminal",                         group = "launcher"}),
        awful.key({ modkey, ctrl  }, "r",       awesome.restart,                                     {  description = "reload awesome",                          group = "awesome"}),
        awful.key({ modkey, shift }, "q",       awesome.quit,                                        {  description = "quit awesome",                            group = "awesome"}),
        awful.key({ modkey,       }, "period",  function () awful.tag.incmwfact( 0.05)          end, {  description = "increase master width factor",            group = "layout"}),
        awful.key({ modkey,       }, "comma",   function () awful.tag.incmwfact(-0.05)          end, {  description = "decrease master width factor",            group = "layout"}),
        awful.key({ modkey, shift }, "comma",   function () awful.tag.incnmaster( 1, nil, true) end, {  description = "increase the number of master clients",   group = "layout"}),
        awful.key({ modkey, shift }, "period",  function () awful.tag.incnmaster(-1, nil, true) end, {  description = "decrease the number of master clients",   group = "layout"}),
        awful.key({ modkey, ctrl  }, "period",  function () awful.tag.incncol( 1, nil, true)    end, {  description = "increase the number of columns",          group = "layout"}),
        awful.key({ modkey, ctrl  }, "comma",   function () awful.tag.incncol(-1, nil, true)    end, {  description = "decrease the number of columns",          group = "layout"}),
        awful.key({ modkey,       }, "space",   function () awful.layout.inc( 1)                end, {  description = "select next",                             group = "layout"}),
        awful.key({ modkey, shift }, "space",   function () awful.layout.inc(-1)                end, {  description = "select previous",                         group = "layout"}),

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

        -- Rofi
        awful.key({ modkey }, "r", function()   awful.spawn("rofi -modi drun,run -show run -location 1 -xoffset " .. panel_config.panel_size) end,      {description = "run rofi launcher", group = "launcher"}),

        awful.key({ modkey,          }, "l",         function()
            awful.spawn.easy_async_with_shell(". "..os.getenv("HOME").."/bin/lock.sh")
        end, {description = "Lock screen",            group = "awesome"}),
        -- FlameShot
        awful.key({                  }, "Print",     function()      awful.spawn.with_shell("flameshot screen --clipboard")                         end, {description = "Take a screenshot of focused screen",  group = "media" }),
        awful.key({ ctrl        }, "Print",     function()      awful.spawn.with_shell("flameshot screen --path "..screenshot_path)      end, {description = "Interactive screenshot",               group = "media" }),
        awful.key({ modkey           }, "Print",     function()      awful.spawn.with_shell("flameshot gui")                                        end, {description = "Interactive screenshot to clipboard",  group = "media" }),
        awful.key({ "Mod1"           }, "Print",     function()      awful.spawn.with_shell("flameshot full --path "..screenshot_path)        end, {description = "Take a screenshot of all screens to file",  group = "media" }),
        awful.key({ "Mod1", ctrl}, "Print",     function()      awful.spawn.with_shell("flameshot full --clipboard")                           end, {description = "Take a screenshot of all screens to clipboard",  group = "media" }),

        -- Audio control
        awful.key({ modkey }, "]", function() volume_widget:inc(5)   end, {description = "Increase sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "[", function() volume_widget:dec(5)   end, {description = "Decrease sound by 5 percent",  group = "media" }),
        awful.key({ modkey }, "\\",function() volume_widget:toggle() end, {description = "Mute out sound",               group = "media" }),

        -- Screen manipulation
        awful.key({ modkey }, "o", awful.client.movetoscreen, {description = "Move window to another screen",               group = "screen" })
    ),

    client = gears.table.join(
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}
        ),
        awful.key({ modkey, shift  }, "c",      function (c) c:kill()                         end, {  description = "close",              group = "client" }),
        awful.key({ modkey, ctrl   }, "space",  awful.client.floating.toggle                     , {  description = "toggle floating",    group = "client" }),
        awful.key({ modkey, ctrl   }, "Return", function (c) c:swap(awful.client.getmaster()) end, {  description = "move to master",     group = "client" }),
        awful.key({ modkey,        }, "o",      function (c) c:move_to_screen()               end, {  description = "move to screen",     group = "client" }),
        awful.key({ modkey,        }, "t",      function (c) c.ontop = not c.ontop            end, {  description = "toggle keep on top", group = "client" }),
        awful.key({ modkey,        }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, ctrl }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, shift   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            {description = "(un)maximize horizontally", group = "client"})
    ),
}

-- Create a wibox for each screen and add it
bindings.taglist_mouse = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
                            if client.focus then
                                client.focus:move_to_tag(t)
                            end
                        end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
                            if client.focus then
                                client.focus:toggle_tag(t)
                            end
                        end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

bindings.tasklist_mouse = gears.table.join(
    awful.button({ }, 1, function (c)
                            if c == client.focus then
                                c.minimized = true
                            else
                                c:emit_signal(
                                    "request::activate",
                                    "tasklist",
                                    {raise = true}
                                )
                            end
                        end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
                            awful.client.focus.byidx(1)
                        end),
    awful.button({ }, 5, function ()
                            awful.client.focus.byidx(-1)
                        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    bindings.keyboard.global = gears.table.join(bindings.keyboard.global,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local current_screen = awful.screen.focused()
                        local tag = current_screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, ctrl }, "#" .. i + 9,
                  function ()
                      local current_screen = awful.screen.focused()
                      local tag = current_screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, shift }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, ctrl, shift }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

return bindings