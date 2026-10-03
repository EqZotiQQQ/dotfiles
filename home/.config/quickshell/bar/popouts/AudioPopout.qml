import QtQuick
import qs.common
import qs.services

// Volume (drag / wheel), mute, output device
Column {
    readonly property int preferredWidth: 400   // the island grows at least this wide
    spacing: 12

    Item {
        width: parent.width
        height: 32

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: "Звук"
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Rectangle {
            anchors.right: parent.right
            width: 32
            height: 32
            radius: 16
            color: Audio.muted ? Theme.primaryContainer : muteMouse.containsMouse ? Theme.surfaceHigh : "transparent"

            StyledText {
                anchors.centerIn: parent
                text: Audio.muted ? Icons.volumeMute : Icons.volumeHigh
                font.family: Theme.iconFont
                font.pixelSize: 16
                color: Audio.muted ? Theme.textOnPrimaryContainer : Theme.text
            }

            MouseArea {
                id: muteMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute()
            }
        }
    }

    Item {
        width: parent.width
        height: 24

        Rectangle {
            id: track

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 56
            height: 8
            radius: 4
            color: Theme.surfaceHigh

            Rectangle {
                id: fill

                width: track.width * Math.min(1, Audio.volume)
                height: parent.height
                radius: 4
                color: Audio.muted ? Theme.outline : Theme.primary
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: fill.width - width / 2
                width: 16
                height: 16
                radius: 8
                color: Audio.muted ? Theme.outline : Theme.primary
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onPressed: event => Audio.setVolume((event.x - 8) / track.width)
                onPositionChanged: event => Audio.setVolume(Math.min(1, (event.x - 8) / track.width))
                onWheel: event => Audio.setVolume(Audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }

        StyledText {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Audio.volume * 100) + "%"
            font.family: Theme.monoFont
        }
    }

    StyledText {
        text: "Устройство вывода"
        font.pixelSize: 12
        color: Theme.textVariant
    }

    Repeater {
        model: Audio.sinks

        delegate: Rectangle {
            id: device

            required property var modelData
            readonly property bool current: Audio.sink === modelData

            width: parent.width
            height: 38
            radius: 14
            color: current ? Theme.primaryContainer : deviceMouse.containsMouse ? Theme.surfaceHigh : "transparent"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 12
                spacing: 10

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: "transparent"
                    border.width: 2
                    border.color: device.current ? Theme.textOnPrimaryContainer : Theme.outline

                    Rectangle {
                        anchors.centerIn: parent
                        width: 6
                        height: 6
                        radius: 3
                        color: Theme.textOnPrimaryContainer
                        visible: device.current
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: device.width - 60
                    text: device.modelData.description || device.modelData.nickname || device.modelData.name
                    elide: Text.ElideRight
                    color: device.current ? Theme.textOnPrimaryContainer : Theme.text
                }
            }

            MouseArea {
                id: deviceMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.setDefault(device.modelData)
            }
        }
    }
}
