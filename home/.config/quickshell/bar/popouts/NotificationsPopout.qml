import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs.services

// Notification center: mako's live notifications (on screen or held back by do-not-disturb), then the
// history, newest first. Click: the live one's default action, then the app's window (a closed app
// without that action is launched); ×: dismiss it.
// Header: bring back the last expired one, do-not-disturb
Column {
    id: root

    signal done   // closes the popout

    readonly property int preferredWidth: 400   // the island grows at least this wide
    spacing: 12

    component IconButton: Rectangle {
        id: button

        property string icon
        property bool checked: false

        signal clicked

        width: 32
        height: width
        radius: width / 2
        color: checked ? Theme.primaryContainer : buttonMouse.containsMouse ? Theme.surfaceHigh : "transparent"

        StyledText {
            anchors.centerIn: parent
            text: button.icon
            font.family: Theme.iconFont
            font.pixelSize: button.width / 2
            color: button.checked ? Theme.textOnPrimaryContainer : Theme.text
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    // "" when the icon theme has none: a bell glyph instead
    function iconFor(n) {
        const icon = n.app_icon ?? "";
        if (icon.startsWith("file://"))
            return icon;
        if (icon.startsWith("/"))
            return "file://" + icon;
        const entry = DesktopEntries.heuristicLookup(n.desktop_entry || n.app_name || "");
        return Quickshell.iconPath(icon || entry?.icon || "", true);
    }

    Component.onCompleted: Mako.markSeen()

    Connections {
        target: Mako

        function onAllChanged() {
            Mako.markSeen();
        }
    }

    Item {
        width: parent.width
        height: 32

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: "Уведомления"
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Row {
            anchors.right: parent.right
            spacing: 4

            IconButton {
                visible: Mako.history.length > 0
                icon: Icons.history
                onClicked: Mako.restore()
            }

            IconButton {
                icon: Mako.dnd ? Icons.bellOff : Icons.bell
                checked: Mako.dnd
                onClicked: Mako.toggle()
            }
        }
    }

    StyledText {
        visible: list.count === 0
        text: "Пусто"
        color: Theme.textVariant
    }

    ListView {
        id: list

        width: parent.width
        height: Math.min(contentHeight, 480)
        visible: count > 0
        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        model: Mako.all

        delegate: Rectangle {
            id: card

            required property var modelData
            readonly property bool hasDefault: modelData.live && modelData.actions?.default !== undefined
            // the app and its window, matched by desktop entry like the dock does
            readonly property var entry: DesktopEntries.heuristicLookup(modelData.desktop_entry || modelData.app_name || "")
            readonly property var window: entry ? ToplevelManager.toplevels.values.find(t => DesktopEntries.heuristicLookup(t.appId) === entry) ?? null : null
            readonly property bool clickable: hasDefault || !!entry
            readonly property string iconSource: root.iconFor(modelData)

            width: ListView.view.width
            height: Math.max(appIcon.height, lines.implicitHeight) + 24
            radius: Theme.tileRadius
            color: clickable && cardMouse.containsMouse ? Theme.primaryContainer : modelData.live ? Theme.surfaceHigh : Theme.alpha(Theme.surfaceHigh, 0.4)

            MouseArea {
                id: cardMouse

                anchors.fill: parent
                hoverEnabled: card.clickable
                cursorShape: card.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (card.clickable) {
                        if (card.hasDefault)
                            Mako.invoke(card.modelData.id);
                        if (card.window)
                            card.window.activate();
                        else if (!card.hasDefault)
                            card.entry.execute();
                        root.done();
                    }
                }
            }

            IconImage {
                id: appIcon

                x: 12
                y: 12
                implicitSize: 32
                asynchronous: true
                source: card.iconSource

                StyledText {
                    anchors.centerIn: parent
                    visible: card.iconSource === ""
                    text: Icons.bell
                    font.family: Theme.iconFont
                    font.pixelSize: 22
                    color: lines.ink
                }
            }

            Column {
                id: lines

                readonly property color ink: card.clickable && cardMouse.containsMouse ? Theme.textOnPrimaryContainer : Theme.text

                anchors.left: appIcon.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: card.modelData.live ? 40 : 12
                y: 12
                spacing: 2

                StyledText {
                    width: parent.width
                    text: card.modelData.app_name ?? ""
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    color: Theme.alpha(lines.ink, 0.65)
                }

                StyledText {
                    width: parent.width
                    text: card.modelData.summary ?? ""
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    font.weight: Font.DemiBold
                    color: card.modelData.urgency === "critical" ? Theme.error : lines.ink
                }

                // body markup is mako's (markup=1): <b>, <i>, entities
                StyledText {
                    width: parent.width
                    visible: text !== ""
                    text: (card.modelData.body ?? "").replace(/\n/g, "<br>")
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    color: Theme.alpha(lines.ink, 0.85)
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 8
                y: 8
                width: 24
                visible: card.modelData.live
                icon: Icons.close
                onClicked: Mako.dismiss(card.modelData.id)
            }
        }
    }
}
