-- Client Signals

local signals = {
    on_manage = "manage", -- signal emited when  client created
    on_unmanage = "unmanage", -- signal emited when clien destroyed
    on_focus = "focus", -- signal emited when app focused
    on_unfocus = "unfocus", -- signal emited when app unfocues
    mouse = {
        on_enter = "mouse::enter", -- signal emited when mouse passes throught app bound
        on_leave = "mouse::leave", -- passes out
        on_move = "mouse::move",
    },
    request = {
        titlebars = "request::titlebars", -- Emited when a client need to get a titlebar
        activate = "request::activate", -- Emited when a client should get activated 
    },
    property = {
        geometry = "property::geometry", -- Emited on resolution change??
        layout = "property::layout",
        floating = "property::floating", -- inokes while free or tiled layout.
    },
    debug = {
        error = "debug::error",
    }
}

return signals