import QtQuick
import qs.common

// Status module: icon + text (+ extra children). The island decides what hover/click/wheel do.
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property bool mono: true            // numbers in the mono font keep their width
    property string widthTemplate: ""   // widest expected text, so changing values don't shift the island
    property bool active: false         // its popout is open
    property color iconColor: active ? Theme.textOnPrimaryContainer : Theme.text
    default property alias extra: row.data

    signal entered
    signal clicked(int button)
    signal wheel(int delta)

    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: row.implicitWidth + 18
    implicitHeight: 36
    radius: Theme.chipRadius
    color: active ? Theme.primaryContainer : mouse.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 160
        }
    }

    TextMetrics {
        id: template

        text: root.widthTemplate
        font: label.font
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 6

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: 16
            color: root.iconColor
        }

        StyledText {
            id: label

            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            width: Math.max(implicitWidth, template.advanceWidth)
            horizontalAlignment: Text.AlignRight
            text: root.text
            font.family: root.mono ? Theme.monoFont : Theme.uiFont
            font.weight: Font.Medium
            color: root.active ? Theme.textOnPrimaryContainer : Theme.text
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onEntered: root.entered()
        onClicked: event => root.clicked(event.button)
        onWheel: event => root.wheel(event.angleDelta.y)
    }
}
