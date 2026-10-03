import QtQuick
import qs.common

// label · bar · value
Item {
    id: root

    property string label
    property real value     // 0..1
    property string detail
    property color barColor: Theme.primary

    implicitHeight: 20

    StyledText {
        id: name

        anchors.verticalCenter: parent.verticalCenter
        width: 56
        text: root.label
        font.pixelSize: 12
        color: Theme.textVariant
    }

    Rectangle {
        anchors.left: name.right
        anchors.right: value.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: 8
        radius: 4
        color: Theme.surfaceHigh

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: 4
            color: root.barColor

            Behavior on width {
                ThemeAnim {}
            }
        }
    }

    StyledText {
        id: value

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 104
        horizontalAlignment: Text.AlignRight
        text: root.detail
        font.family: Theme.monoFont
        font.pixelSize: 12
    }
}
