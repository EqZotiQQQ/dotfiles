//@ pragma IconTheme Papirus-Dark-Maia
// Icon theme as in qt6ct (qs doesn't read it): without one Qt sees only hicolor, and tray apps ask for
// theme icons (Telegram: org.telegram.desktop-attention-symbolic). Read at start: restart qs after a change.
// Quickshell config: per screen a bar and the spectrum strip behind it, plus the app launcher (SUPER+R:
// `qs ipc call launcher toggle`) and the workspace overview (SUPER+Tab: `qs ipc call overview toggle`).
// Started by Hyprland (hyprland.lua autostart: `qs`).
// Look and bar edge: ~/.config/theme/theme.json (common/Theme.qml)
import QtQuick
import Quickshell
import qs.bar
import qs.launcher
import qs.overview

ShellRoot {
    Launcher {}
    Overview {}

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
