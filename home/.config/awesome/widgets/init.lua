local taskbar_widget = require("widgets.taskbar")
local layout_box_widget = require("widgets.layout_box")
local taglist_widget = require("widgets.taglist")
local clock_widget = require("widgets.clock")

local dbg = require("dbg")

local screen_widgets = {}

function screen_widgets.full_init_taskbar(screen)
    local tasklist = dbg.w(taglist_widget.create_tag_list(screen), "green")
    local layout_box = dbg.w(layout_box_widget.create_layout_box(screen), "red")
    local clock = dbg.w(clock_widget.create_clock(), "blue")
    local taskbar = taskbar_widget.init_taskbar(screen, tasklist, layout_box, clock)
    screen.taskbar = taskbar
end

function screen_widgets.init_screen_widgets()
    screen.connect_signal(
        "request::desktop_decoration",
        function(screen)
            screen_widgets.full_init_taskbar(screen)
        end
    )
end

return screen_widgets
