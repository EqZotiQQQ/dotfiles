import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common

// Workspaces of one monitor, numbered 1..9 along the bar: Hyprland ids 1-9 live on the main monitor, 10-18 on
// the second and so on (hypr/monitors.lua: workspace rules and keys). Hyprland only keeps active or
// occupied workspaces, so empty ones are skipped. Wheel: next/previous workspace on this monitor.
Strip {
    id: root

    required property HyprlandMonitor monitor

    spacing: 2

    WheelHandler {
        onWheel: event => Hyprland.dispatch(`hl.dsp.focus({ workspace = "m${event.angleDelta.y > 0 ? "-" : "+"}1" })`)
    }

    Repeater {
        model: ScriptModel {
            values: Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor === root.monitor).sort((a, b) => a.id - b.id)
        }

        delegate: Rectangle {
            id: pill

            required property HyprlandWorkspace modelData
            readonly property bool active: root.monitor?.activeWorkspace === modelData
            readonly property bool occupied: modelData.toplevels.values.length > 0

            // the active one is longer along the bar
            width: active && !Theme.barVertical ? 36 : 26
            height: active && Theme.barVertical ? 36 : 26
            radius: 13
            color: active ? Theme.primary : mouse.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"

            Behavior on width {
                ThemeAnim {}
            }
            Behavior on height {
                ThemeAnim {}
            }
            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }

            StyledText {
                anchors.centerIn: parent
                text: (pill.modelData.id - 1) % 9 + 1
                font.weight: pill.active ? Font.DemiBold : Font.Medium
                color: pill.active ? Theme.textOnPrimary : pill.occupied ? Theme.text : Theme.textVariant
            }

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: pill.modelData.activate()
            }
        }
    }
}
