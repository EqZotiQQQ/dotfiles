local awful = require("awful")

local client_bindings = require("client_bindings")
local global_bindings = require("global_bindings")

-- Apply global and client bindings
root.keys(global_bindings.keyboard_bindings)
root.buttons(global_bindings.mouse_bindings)
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings(client_bindings.keyboard_bindings)
end)
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings(client_bindings.mouse_bindings)
end)
