// Quickshell config: per screen a bar and the spectrum strip behind it, plus the app launcher (SUPER+R:
// `qs ipc call launcher toggle`). Started by Hyprland (hyprland.lua autostart: `qs`).
// Look and bar edge: ~/.config/theme/theme.json (common/Theme.qml)
import QtQuick
import Quickshell
import qs.bar
import qs.launcher

ShellRoot {
    Launcher {}

    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen

            required property var modelData

            Bar {
                modelData: perScreen.modelData
            }

            Spectrum {
                screen: perScreen.modelData
            }
        }
    }
}
