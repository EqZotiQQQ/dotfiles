// Quickshell config: one bar per screen. Started by Hyprland (hyprland.lua autostart: `qs`).
// Look: ~/.config/theme/theme.json (common/Theme.qml)
import QtQuick
import Quickshell
import qs.bar

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
