import QtQuick
import qs.common

// Popout title, with an optional detail on the right
Item {
    property string title
    property string detail

    implicitHeight: 24

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        text: parent.title
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    StyledText {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: parent.detail
        color: Theme.textVariant
    }
}
