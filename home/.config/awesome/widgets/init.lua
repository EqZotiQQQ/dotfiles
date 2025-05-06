local close_to_default_taskbar = require("widgets.close_to_default_taskbar")
local left_taskbar = require("widgets.my_taskbar")

local widgets = {
    taskbar = left_taskbar,
    close_to_default_taskbar = close_to_default_taskbar,
}

local screen_widgets = {}

function screen_widgets.init_panel()
    screen.connect_signal(
        "request::desktop_decoration",
        function(screen)
            widgets.taskbar.full_init_taskbar(screen)
        end
    )
end

return screen_widgets
