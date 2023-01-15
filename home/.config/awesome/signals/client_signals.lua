-- Client Signals

local signals = {
    on_manage = "manage", -- signal invokes when  client created
    on_unmanage = "unmanage", -- signal invokes when clien destroyed
    on_focus = "focus", -- signal invokes when app focused
    on_unfocus = "unfocus", -- signal invokes when app unfocues
    mouse = {
        on_enter = "mouse::enter",
        on_leave = "mouse::leave",
        on_move = "mouse::move",
    },
    request = {
        on_titlebars = "request::titlebars",
    },
    property = {
        geometry = "geometry",
        layout = "layout",
        floating = "floating", -- inokes while free or tiled layout.
    },
}

return signals