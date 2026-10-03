import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Top bar of one screen: three floating islands over the spectrum strip (layer "background").
// The surface is taller than the bar so the status island can grow its popouts downwards;
// only the islands take input (mask), the rest of the surface is click-through.
PanelWindow {
    id: bar

    required property var modelData
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
    // the bar is on layer "top", above windows, so it steps aside for a fullscreen one (not a maximized one)
    readonly property bool fullscreen: monitor?.activeWorkspace?.toplevels.values.some(t => t.wayland?.fullscreen) ?? false

    screen: modelData
    visible: !fullscreen
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barMargin + Theme.barHeight + 560
    exclusiveZone: Theme.barMargin + Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "quickshell-bar"

    mask: Region {
        item: left

        Region {
            item: dock
        }
        Region {
            item: status
        }
    }

    // Workspaces of this monitor + the active window's title
    Rectangle {
        id: left

        x: Theme.barMargin
        y: Theme.barMargin
        width: leftRow.implicitWidth + 22
        height: Theme.barHeight
        radius: Theme.islandRadius
        color: Theme.panel
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.5)

        Behavior on width {
            ThemeAnim {}
        }

        Row {
            id: leftRow

            x: 11
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Workspaces {
                anchors.verticalCenter: parent.verticalCenter
                monitor: bar.monitor
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: Theme.outlineVariant
                visible: title.visible
            }

            ActiveWindow {
                id: title

                anchors.verticalCenter: parent.verticalCenter
                monitor: bar.monitor
            }
        }
    }

    Dock {
        id: dock

        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.barMargin
    }

    StatusIsland {
        id: status

        anchors.right: parent.right
        anchors.rightMargin: Theme.barMargin
        y: Theme.barMargin
    }
}
