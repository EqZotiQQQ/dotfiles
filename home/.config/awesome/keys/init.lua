local awful = require("awful")
local gears = require("gears")
local dbg = require("dbg")
local tag_navigation_bindings = require("tags.global_bindings")
-- local client_bindings = require("client_bindings")
-- local global_bindings = require("global_bindings")

-- Apply global and client bindings

local bindings_module = {}

function bindings_module.init_glob_bindings()
    -- local globalkeys = gears.table.join(
    --     tag_navigation_bindings.move_client_to_tag,
    --     tag_navigation_bindings.tag_keys,
    --     tag_navigation_bindings.toggle_tag_view
    -- )

    globalkeys = gears.table.join(
        tag_navigation_bindings.move_client_to_tag,
        tag_navigation_bindings.tag_keys,
        tag_navigation_bindings.toggle_tag_view
    )

    root.keys(globalkeys)
    root.buttons({})

    client.connect_signal("request::default_keybindings", function()
        -- awful.keyboard.append_client_keybindings(client_bindings.keyboard_bindings)
    end)
    client.connect_signal("request::default_mousebindings", function()
        -- awful.mouse.append_client_mousebindings(client_bindings.mouse_bindings)
    end)
end

return bindings_module
