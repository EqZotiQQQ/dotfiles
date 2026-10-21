---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Dispatchers/ for more
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + SHIFT + Q",     hl.dsp.exec_cmd("kill $(hyprctl activewindow -j | jq .pid)"))
-- Spotify сам Ctrl+W не обрабатывает; остальным окнам клавиша проходит как обычно (non_consuming)
hl.bind("CTRL + W", function()
    local w = hl.get_active_window()
    if w and w.class == "Spotify" then hl.dispatch(hl.dsp.window.close()) end
end, { non_consuming = true })
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Tab",    hl.dsp.exec_cmd("qs ipc call overview toggle")) -- обзор воркспейсов (quickshell/overview)
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())      -- dwindle
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit")) -- dwindle

-- Layout of the focused workspace, AwesomeWM style: next / previous (layouts.lua; the icon is on the bar)
local layouts = require("layouts")
hl.bind(mainMod .. " + CTRL + SPACE",         function() layouts.cycle(1) end)
hl.bind(mainMod .. " + CTRL + SHIFT + SPACE", function() layouts.cycle(-1) end)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [1-9] (per-monitor, AwesomeWM style)
-- Move active window to workspace with mainMod + SHIFT + [1-9] (per-monitor)
-- Key i -> the i-th workspace of the focused monitor (ids per monitor: monitors.lua)
local monitors = require("monitors")
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, function()
        hl.dispatch(hl.dsp.focus({ workspace = tostring(monitors.focused_workspace(i)) }))
    end)
    hl.bind(mainMod .. " + SHIFT + " .. i, function()
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(monitors.focused_workspace(i)), follow = false }))
    end)
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Клик мимо wofi закрывает его. Сам wofi этого не умеет: он держит клавиатуру эксклюзивно, фокус от него
-- по клику не уходит, и close_on_focus_loss не срабатывает. Клик всё равно доходит до окна (non_consuming)
for _, button in ipairs({ "mouse:272", "mouse:273" }) do
    hl.bind(button, function()
        local c = hl.get_cursor_pos()
        for _, l in ipairs(hl.get_layers({ namespace = "wofi" })) do
            if c.x < l.x or c.x >= l.x + l.w or c.y < l.y or c.y >= l.y + l.h then
                hl.exec_cmd("pkill -x wofi")
            end
        end
    end, { non_consuming = true })
end

-- Language switching
hl.bind("ALT + Shift_L",         hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + SPACE",   hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Clipboard (X11-style Insert shortcuts), requires: wtype wl-clipboard
hl.bind("CTRL + Insert",  hl.dsp.exec_cmd("wtype -M ctrl c -m ctrl"))
hl.bind("SHIFT + Insert", hl.dsp.exec_cmd("wl-paste | wtype -"))

-- Screenshots. hyprshot на Manjaro из пакета (/usr/bin), на Ubuntu — в ~/.local/bin, которого нет в PATH у Hyprland
local hyprshot = "PATH=$HOME/.local/bin:$PATH hyprshot -o ~/Pictures/Screenshots -m "
hl.bind("Print",              hl.dsp.exec_cmd(hyprshot .. "region"))
hl.bind("SHIFT + Print",      hl.dsp.exec_cmd(hyprshot .. "output"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(hyprshot .. "window"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
