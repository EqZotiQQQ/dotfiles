import QtQuick
import qs.common

// Status module: icon + value, side by side on a horizontal bar, stacked on a vertical one.
// The island decides what hover/click/wheel do.
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property string note: ""            // dimmer text after the value, horizontal bar only
    property bool mono: true            // numbers in the mono font
    property int textSize: Theme.barVertical ? 11 : Theme.fontSize
    property string widthTemplate: ""   // widest expected value: on a horizontal bar changing values don't shift the island
    property bool active: false         // its popout is open
    property color iconColor: active ? Theme.textOnPrimaryContainer : Theme.text

    signal entered
    signal clicked(int button)
    signal wheel(int delta)

    implicitWidth: Theme.barVertical ? Theme.barSize - 8 : content.implicitWidth + 18
    implicitHeight: Theme.barVertical ? content.implicitHeight + 10 : 36
    radius: Math.min(Theme.chipRadius, width / 2, height / 2)
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

    Grid {
        id: content

        anchors.centerIn: parent
        columns: Theme.barVertical ? 1 : 3
        columnSpacing: 6
        rowSpacing: 1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        StyledText {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.iconFont
            font.pixelSize: 16
            color: root.iconColor
        }

        StyledText {
            id: label

            visible: root.text !== ""
            width: Theme.barVertical ? implicitWidth : Math.max(implicitWidth, template.advanceWidth)
            horizontalAlignment: Theme.barVertical ? Text.AlignHCenter : Text.AlignRight
            lineHeight: 0.95
            text: root.text
            font.family: root.mono ? Theme.monoFont : Theme.uiFont
            font.pixelSize: root.textSize
            font.weight: root.mono ? Font.Medium : Font.DemiBold
            color: root.active ? Theme.textOnPrimaryContainer : Theme.text
        }

        StyledText {
            visible: !Theme.barVertical && root.note !== ""
            text: root.note
            color: root.active ? Theme.textOnPrimaryContainer : Theme.textVariant
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
