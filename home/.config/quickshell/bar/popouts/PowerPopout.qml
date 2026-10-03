import QtQuick
import Quickshell
import qs.common

// Lock / sleep / log out / reboot / power off
Row {
    id: root

    signal done   // closes the popout

    readonly property var actions: [
        { icon: Icons.lock, label: "Блокировка", command: ["loginctl", "lock-session"] },
        { icon: Icons.sleep, label: "Сон", command: ["systemctl", "suspend"] },
        { icon: Icons.logout, label: "Выход", command: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { icon: Icons.restart, label: "Перезагрузка", command: ["systemctl", "reboot"] },
        { icon: Icons.power, label: "Выключение", command: ["systemctl", "poweroff"] }
    ]

    readonly property int preferredWidth: 460   // the island grows at least this wide
    spacing: 8

    Repeater {
        model: root.actions

        delegate: Rectangle {
            id: action

            required property var modelData

            width: (root.width - 4 * root.spacing) / 5
            height: 76
            radius: Theme.tileRadius
            color: actionMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceHigh

            Column {
                anchors.centerIn: parent
                spacing: 6

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: action.modelData.icon
                    font.family: Theme.iconFont
                    font.pixelSize: 22
                    color: actionMouse.containsMouse ? Theme.textOnPrimaryContainer : Theme.text
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: action.modelData.label
                    font.pixelSize: 12
                    color: actionMouse.containsMouse ? Theme.textOnPrimaryContainer : Theme.textVariant
                }
            }

            MouseArea {
                id: actionMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(action.modelData.command);
                    root.done();
                }
            }
        }
    }
}
