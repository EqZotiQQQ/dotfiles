local taskbar = require("widgets.taskbar")

local widgets = {
    taskbar = taskbar.my_taskbar,
    close_to_default_taskbar = taskbar.close_to_default_taskbar,
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
