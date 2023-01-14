-- Client Signals

local signals = {
    on_manage = "manage", -- signal invokes when  client created
    on_unmanage = "unmanage", -- signal invokes when clien destroyed
    on_focus = "focus", -- signal invokes when app focused
    on_unfocus = "unfocus", -- signal invokes when app unfocues
    floating = {
        property_floating = "property::floating", -- inokes while free or tiled layout.
    },
    mouse = {
        on_enter = "enter",
        on_leave = "leave",
        on_move = "move",
    },
    request = {
        on_titlebars = "request::titlebars",
    },
}

return signals