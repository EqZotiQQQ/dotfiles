local awful = require("awful")
local gears = require("gears")

local bindings = {}

bindings.tag_keys = awful.key {
    modifiers   = { "Mod1" }, -- Alt
    keygroup    = "numrow",
    description = "view tag #",
    group       = "tag",
    on_press    = function(tag_index)
        local screen = awful.screen.focused()
        local tag = screen.tags[tag_index]
        if tag then tag:view_only() end
    end
}

bindings.move_client_to_tag = awful.key {
    modifiers   = { "Mod1", "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag #",
    group       = "tag",
    on_press    = function(tag_index)
        if client.focus then
            local tag = client.focus.screen.tags[tag_index]
            if tag then client.focus:move_to_tag(tag) end
        end
    end
}

bindings.toggle_tag_view = awful.key {
    modifiers   = { "Mod1", "Control" },
    keygroup    = "numrow",
    description = "toggle tag #",
    group       = "tag",
    on_press    = function(tag_index)
        local screen = awful.screen.focused()
        local tag = screen.tags[tag_index]
        if tag then tag.selected = not tag.selected end
    end
}

return bindings
