import QtQuick
import Quickshell.Hyprland
import qs.common
import qs.services

// Layout of this monitor's workspace as a small picture, like AwesomeWM's layoutbox. Switched per workspace
// with SUPER+CTRL+Space (SHIFT: back) or here: click / wheel up — next, right click / wheel down — previous.
Item {
    id: root

    required property HyprlandMonitor monitor
    readonly property int workspace: monitor?.activeWorkspace?.id ?? 0
    readonly property string layout: Layouts.of(workspace)

    // the windows of each layout (names: hypr/layouts.lua): x, y, width, height as parts of the picture;
    // scrolling's outer columns are cut by its edge
    readonly property var shapes: ({
            "dwindle": [[0, 0, 0.5, 1], [0.5, 0, 0.5, 0.5], [0.5, 0.5, 0.25, 0.5], [0.75, 0.5, 0.25, 0.5]],
            "tile": [[0, 0, 0.6, 1], [0.6, 0, 0.4, 0.5], [0.6, 0.5, 0.4, 0.5]],
            "tile.left": [[0.4, 0, 0.6, 1], [0, 0, 0.4, 0.5], [0, 0.5, 0.4, 0.5]],
            "tile.bottom": [[0, 0, 1, 0.6], [0, 0.6, 0.5, 0.4], [0.5, 0.6, 0.5, 0.4]],
            "tile.top": [[0, 0.4, 1, 0.6], [0, 0, 0.5, 0.4], [0.5, 0, 0.5, 0.4]],
            "scrolling": [[-0.3, 0, 0.5, 1], [0.25, 0, 0.5, 1], [0.8, 0, 0.5, 1]]
        })

    visible: workspace > 0 && layout in shapes
    implicitWidth: 22
    implicitHeight: 16
    clip: true

    Repeater {
        model: root.shapes[root.layout] ?? []

        // a 2px gap between neighbours
        delegate: Rectangle {
            required property var modelData

            x: Math.round(modelData[0] * root.width) + 1
            y: Math.round(modelData[1] * root.height) + 1
            width: Math.round(modelData[2] * root.width) - 2
            height: Math.round(modelData[3] * root.height) - 2
            radius: 2
            color: mouse.containsMouse ? Theme.text : Theme.textVariant
        }
    }

    WheelHandler {
        onWheel: event => Layouts.cycle(event.angleDelta.y > 0 ? 1 : -1, root.workspace)
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => Layouts.cycle(event.button === Qt.RightButton ? -1 : 1, root.workspace)
    }
}
