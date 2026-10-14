import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.common
import qs.services

// Current MPRIS player: cover, track, position (click / drag to seek), controls.
// Several players: tabs to switch between them
Column {
    id: root

    signal done   // closes the popout

    readonly property MprisPlayer player: Media.player
    readonly property int preferredWidth: 400   // the island grows at least this wide
    spacing: 14

    // the player quit
    onPlayerChanged: if (!player) done()

    component IconButton: Rectangle {
        id: button

        property string icon
        property bool checked: false
        property color ink: checked ? Theme.textOnPrimaryContainer : Theme.text
        readonly property bool hovered: buttonMouse.containsMouse

        signal clicked

        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: width
        radius: width / 2
        opacity: enabled ? 1 : 0.4
        color: checked ? Theme.primaryContainer : hovered ? Theme.surfaceHigh : "transparent"

        StyledText {
            anchors.centerIn: parent
            text: button.icon
            font.family: Theme.iconFont
            font.pixelSize: button.width / 2
            color: button.ink
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    // MPRIS doesn't push the position while playing: re-read it
    Timer {
        running: root.player?.isPlaying ?? false
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Item {
        width: parent.width
        height: 32

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: Media.players.length < 2
            text: root.player?.identity ?? ""
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Row {
            visible: Media.players.length > 1
            spacing: 4

            Repeater {
                model: Media.players

                delegate: Rectangle {
                    id: tab

                    required property MprisPlayer modelData
                    readonly property bool current: modelData === root.player

                    width: tabLabel.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: current ? Theme.primaryContainer : tabMouse.containsMouse ? Theme.surfaceHigh : "transparent"

                    StyledText {
                        id: tabLabel

                        anchors.centerIn: parent
                        text: tab.modelData.identity
                        color: tab.current ? Theme.textOnPrimaryContainer : Theme.text
                    }

                    MouseArea {
                        id: tabMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Media.chosen = tab.modelData
                    }
                }
            }
        }
    }

    Row {
        width: parent.width
        spacing: 14

        ClippingRectangle {
            id: art

            width: 96
            height: 96
            radius: Theme.tileRadius
            color: Theme.surfaceHigh

            StyledText {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                text: Icons.music
                font.family: Theme.iconFont
                font.pixelSize: 36
                color: Theme.textVariant
            }

            Image {
                id: cover

                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                sourceSize.width: 192
                sourceSize.height: 192
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - art.width - parent.spacing
            spacing: 4

            StyledText {
                width: parent.width
                text: root.player?.trackTitle || "—"
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            StyledText {
                width: parent.width
                visible: text !== ""
                text: root.player?.trackArtist ?? ""
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.textVariant
            }

            StyledText {
                width: parent.width
                visible: text !== ""
                text: root.player?.trackAlbum ?? ""
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.pixelSize: 12
                color: Theme.textVariant
            }
        }
    }

    // position; a drag shows where it will seek to and seeks on release
    Column {
        width: parent.width
        visible: Media.hasLength
        spacing: 6

        Item {
            id: progress

            readonly property real length: root.player?.length ?? 0
            readonly property real fraction: seek.pressed ? seek.fraction : length > 0 ? Math.min(1, (root.player?.position ?? 0) / length) : 0

            width: parent.width
            height: 12

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: Theme.surfaceHigh

                Rectangle {
                    id: fill

                    width: parent.width * progress.fraction
                    height: parent.height
                    radius: 3
                    color: Theme.primary
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: fill.width - width / 2
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.primary
                    visible: seek.enabled
                }
            }

            MouseArea {
                id: seek

                readonly property real fraction: Math.max(0, Math.min(1, mouseX / width))

                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                enabled: (root.player?.canSeek ?? false) && root.player.positionSupported
                cursorShape: Qt.PointingHandCursor
                onReleased: root.player.position = fraction * progress.length
            }
        }

        Item {
            width: parent.width
            height: elapsed.implicitHeight

            StyledText {
                id: elapsed

                text: Media.fmt(progress.fraction * progress.length)
                font.family: Theme.monoFont
                font.pixelSize: 12
                color: Theme.textVariant
            }

            StyledText {
                anchors.right: parent.right
                text: Media.fmt(progress.length)
                font.family: Theme.monoFont
                font.pixelSize: 12
                color: Theme.textVariant
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        IconButton {
            visible: root.player?.shuffleSupported ?? false
            icon: Icons.shuffle
            checked: root.player?.shuffle ?? false
            onClicked: root.player.shuffle = !root.player.shuffle
        }

        IconButton {
            icon: Icons.skipPrevious
            enabled: root.player?.canGoPrevious ?? false
            onClicked: root.player.previous()
        }

        IconButton {
            width: 52
            icon: root.player?.isPlaying ? Icons.pause : Icons.play
            enabled: root.player?.canTogglePlaying ?? false
            color: hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
            ink: Theme.textOnPrimary
            onClicked: root.player.togglePlaying()
        }

        IconButton {
            icon: Icons.skipNext
            enabled: root.player?.canGoNext ?? false
            onClicked: root.player.next()
        }

        // off -> playlist -> track
        IconButton {
            readonly property int loop: root.player?.loopState ?? MprisLoopState.None

            visible: root.player?.loopSupported ?? false
            icon: loop === MprisLoopState.Track ? Icons.repeatOnce : Icons.repeat
            checked: loop !== MprisLoopState.None
            onClicked: root.player.loopState = loop === MprisLoopState.None ? MprisLoopState.Playlist : loop === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
        }
    }
}
