// Quickshell config: per screen a bar and the spectrum strip behind it. Started by Hyprland
// (hyprland.lua autostart: `qs`). Look and bar edge: ~/.config/theme/theme.json (common/Theme.qml)
import QtQuick
import Quickshell
import qs.bar

ShellRoot {
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
