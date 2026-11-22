import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

PopupWindow {
    id: root

    required property HyprlandWorkspace workspace
    readonly property real zoom: (width - 16) / screen.width

    visible: workspace !== null
    implicitWidth: Math.min(400, screen.width * 0.4)
    implicitHeight: screen.height * zoom + 44
    color: "transparent"
    anchor.edges: Theme.barPosition === "top" ? Edges.Bottom | Edges.Left
        : Theme.barPosition === "bottom" ? Edges.Top | Edges.Left
        : Theme.barPosition === "left" ? Edges.Right | Edges.Top : Edges.Left | Edges.Top
    anchor.gravity: Theme.barPosition === "top" ? Edges.Bottom | Edges.Right
        : Theme.barPosition === "bottom" ? Edges.Top | Edges.Right
        : Theme.barPosition === "left" ? Edges.Right | Edges.Bottom : Edges.Left | Edges.Bottom

    Rectangle {
        anchors.fill: parent
        radius: Theme.tileRadius
        color: Theme.popoutPanel
        border.width: 1
        border.color: Theme.outlineVariant

        StyledText {
            x: 8
            y: 6
            text: root.workspace ? "Workspace " + ((root.workspace.id - 1) % 9 + 1) : ""
            font.weight: Font.DemiBold
        }

        ClippingRectangle {
            x: 8
            y: 36
            width: parent.width - 16
            height: parent.height - 44
            radius: Math.max(0, Theme.tileRadius - 4)
            color: Theme.surface

            Repeater {
                model: ScriptModel {
                    values: Hyprland.toplevels.values.filter(t => root.workspace && t.workspace === root.workspace && t.lastIpcObject.at && !t.lastIpcObject.hidden).sort((a, b) => a.lastIpcObject.floating - b.lastIpcObject.floating)
                }

                delegate: Rectangle {
                    id: win

                    required property HyprlandToplevel modelData
                    readonly property var ipc: modelData.lastIpcObject

                    x: (ipc.at[0] - root.screen.x) * root.zoom
                    y: (ipc.at[1] - root.screen.y) * root.zoom
                    width: ipc.size[0] * root.zoom
                    height: ipc.size[1] * root.zoom
                    color: Theme.surfaceHigh

                    ScreencopyView {
                        anchors.fill: parent
                        captureSource: root.visible ? win.modelData.wayland : null
                        live: true
                    }
                }
            }
        }
    }
}
