import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.common

// Menu of a tray app (its D-Bus menu). Click: the entry's action; a submenu opens in place of the menu,
// the row above it goes back
Column {
    id: root

    property SystemTrayItem item: null
    property var path: []   // submenus opened on the way, the last one is shown
    // check boxes / icons in this menu: all texts line up after them
    readonly property bool leading: menu.children.values.some(e => e.buttonType !== QsMenuButtonType.None || e.icon !== "")

    signal done   // closes the popout

    readonly property int preferredWidth: 280   // the island grows at least this wide
    spacing: 8

    onItemChanged: path = []

    QsMenuOpener {
        id: menu

        menu: root.path.length > 0 ? root.path[root.path.length - 1] : root.item?.menu ?? null
    }

    Header {
        width: parent.width
        title: root.item?.tooltipTitle || root.item?.title || root.item?.id || ""
    }

    Rectangle {
        visible: root.path.length > 0
        width: parent.width
        height: 34
        radius: 12
        color: backMouse.containsMouse ? Theme.surfaceHigh : "transparent"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: 8
            spacing: 6

            StyledText {
                text: Icons.chevronLeft
                font.family: Theme.iconFont
                font.pixelSize: 18
            }

            StyledText {
                text: root.path[root.path.length - 1]?.text ?? ""
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: backMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.path = root.path.slice(0, -1)
        }
    }

    ListView {
        width: parent.width
        height: Math.min(contentHeight, 440)
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: menu.children

        delegate: Rectangle {
            id: entry

            required property QsMenuEntry modelData
            readonly property bool clickable: !modelData.isSeparator && modelData.enabled
            readonly property bool checked: modelData.checkState === Qt.Checked

            width: ListView.view.width
            height: modelData.isSeparator ? 9 : 34
            radius: 12
            color: clickable && entryMouse.containsMouse ? Theme.surfaceHigh : "transparent"

            Rectangle {
                visible: entry.modelData.isSeparator
                anchors.centerIn: parent
                width: parent.width - 24
                height: 1
                color: Theme.outlineVariant
            }

            // check box / radio button, else the entry's icon
            StyledText {
                visible: entry.modelData.buttonType !== QsMenuButtonType.None
                anchors.verticalCenter: parent.verticalCenter
                x: 12
                text: entry.modelData.buttonType === QsMenuButtonType.RadioButton ? (entry.checked ? Icons.radioOn : Icons.radioOff) : (entry.checked ? Icons.checkboxOn : Icons.checkboxOff)
                font.family: Theme.iconFont
                font.pixelSize: 16
                color: entry.checked ? Theme.primary : Theme.textVariant
            }

            IconImage {
                visible: entry.modelData.buttonType === QsMenuButtonType.None && entry.modelData.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
                x: 12
                implicitSize: 16
                source: entry.modelData.icon
            }

            StyledText {
                visible: !entry.modelData.isSeparator
                anchors.verticalCenter: parent.verticalCenter
                x: root.leading ? 38 : 12
                width: parent.width - x - 30
                text: entry.modelData.text
                elide: Text.ElideRight
                color: entry.modelData.enabled ? Theme.text : Theme.alpha(Theme.textVariant, 0.5)
            }

            StyledText {
                visible: entry.modelData.hasChildren
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 8
                text: Icons.chevronRight
                font.family: Theme.iconFont
                font.pixelSize: 18
                color: Theme.textVariant
            }

            MouseArea {
                id: entryMouse

                anchors.fill: parent
                hoverEnabled: entry.clickable
                cursorShape: entry.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (!entry.clickable)
                        return;
                    if (entry.modelData.hasChildren) {
                        root.path = root.path.concat([entry.modelData]);
                    } else {
                        entry.modelData.triggered();
                        root.done();
                    }
                }
            }
        }
    }
}
