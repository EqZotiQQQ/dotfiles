-- local module_path = (...):match ("(.+/)[^/]+$") or ""

local d = require("dbg")
package.loaded.net_widgets = nil

-- d.notify_persistent("Module path: "..module_path)
local net_widgets = {
    indicator   = require("widgets.network_widgets.indicator"),
    wireless    = require("widgets.network_widgets.wireless"),
    internet    = require("widgets.network_widgets.internet")
}

return net_widgets
