import QtQuick
import qs.common

// process name · value
Item {
    property string name
    property string value

    implicitHeight: 18

    StyledText {
        anchors.left: parent.left
        anchors.right: amount.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: parent.name
        elide: Text.ElideRight
        font.family: Theme.monoFont
        font.pixelSize: 12
    }

    StyledText {
        id: amount

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: parent.value
        font.family: Theme.monoFont
        font.pixelSize: 12
        color: Theme.primary
    }
}
