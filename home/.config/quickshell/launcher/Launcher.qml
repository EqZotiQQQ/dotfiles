import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

// App launcher in the bar's look, an alternative to wofi. NOT active yet: to switch over, add `Launcher {}`
// (+ `import qs.launcher`) to ShellRoot in shell.qml and set `menu = "qs ipc call launcher toggle"` in hyprland.lua.
// Opens on the focused monitor. Query words match name, generic name, description and keywords in any order,
// name matches go first. ↑↓ / Tab choose, Enter runs, Esc or a click outside closes.
Scope {
    id: root

    property bool open: false
    // bound from startup: Hyprland fills it in asynchronously, a first read at toggle time is still empty
    readonly property HyprlandMonitor monitor: Hyprland.focusedMonitor

    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay).sort((a, b) => a.name.localeCompare(b.name))

    function matches(query) {
        const q = query.trim().toLowerCase();
        if (q === "")
            return apps;
        const words = q.split(/\s+/);
        const found = [];
        for (const e of apps) {
            const name = e.name.toLowerCase();
            const text = [name, e.genericName, e.comment, e.keywords.join(" ")].join(" ").toLowerCase();
            if (words.every(w => text.includes(w)))
                found.push({ entry: e, rank: name.startsWith(q) ? 0 : name.includes(q) ? 1 : 2 });
        }
        return found.sort((a, b) => a.rank - b.rank).map(f => f.entry);
    }

    function toggle() {
        if (!open)
            window.screen = Quickshell.screens.find(s => s.name === monitor?.name) ?? window.screen;
        open = !open;
    }

    function launch(entry) {
        entry.execute();
        open = false;
    }

    // qs ipc call launcher toggle
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }
    }

    PanelWindow {
        id: window

        readonly property var results: root.matches(search.text)

        visible: root.open
        implicitWidth: 560
        implicitHeight: 600
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-launcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // only the box takes input: a click beside it ends the focus grab and closes the launcher
        mask: Region {
            item: box
        }

        onVisibleChanged: {
            if (!visible)
                return;
            search.text = "";
            list.currentIndex = 0;
            search.forceActiveFocus();
        }

        HyprlandFocusGrab {
            windows: [window]
            active: window.visible
            onCleared: root.open = false
        }

        // hangs from the top of the centered surface: the search field stays put while the list shrinks
        Rectangle {
            id: box

            width: parent.width
            height: content.implicitHeight + 24
            radius: Theme.islandRadius
            color: Theme.popoutPanel
            border.width: 1
            border.color: Theme.alpha(Theme.outlineVariant, 0.5)
            transformOrigin: Item.Top
            scale: root.open ? 1 : 0.94

            Behavior on height {
                ThemeAnim {}
            }
            Behavior on scale {
                ThemeAnim {}
            }

            Column {
                id: content

                x: 12
                y: 12
                width: parent.width - 24
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: Theme.chipRadius
                    color: Theme.surfaceHigh

                    StyledText {
                        id: glyph

                        anchors.verticalCenter: parent.verticalCenter
                        x: 14
                        text: Icons.magnify
                        font.family: Theme.iconFont
                        font.pixelSize: 18
                        color: Theme.textVariant
                    }

                    TextInput {
                        id: search

                        anchors.left: glyph.right
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        color: Theme.text
                        selectionColor: Theme.primaryContainer
                        selectedTextColor: Theme.textOnPrimaryContainer
                        font.family: Theme.uiFont
                        font.pixelSize: Theme.fontSize + 2
                        onTextChanged: list.currentIndex = 0

                        Keys.onPressed: event => {
                            switch (event.key) {
                            case Qt.Key_Escape:
                                root.open = false;
                                break;
                            case Qt.Key_Down:
                            case Qt.Key_Tab:
                                list.currentIndex = Math.min(list.currentIndex + 1, list.count - 1);
                                break;
                            case Qt.Key_Up:
                            case Qt.Key_Backtab:
                                list.currentIndex = Math.max(list.currentIndex - 1, 0);
                                break;
                            case Qt.Key_Return:
                            case Qt.Key_Enter:
                                if (list.count > 0)
                                    root.launch(window.results[list.currentIndex]);
                                break;
                            default:
                                return;
                            }
                            event.accepted = true;
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Запуск приложения"
                            font.pixelSize: Theme.fontSize + 2
                            color: Theme.textVariant
                            visible: search.text === ""
                        }
                    }
                }

                ListView {
                    id: list

                    width: parent.width
                    height: Math.min(count, 8) * 48
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: window.results
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Rectangle {
                        id: row

                        required property var modelData
                        readonly property bool current: ListView.isCurrentItem

                        width: ListView.view.width
                        height: 48
                        radius: Theme.tileRadius
                        color: current ? Theme.primaryContainer : rowMouse.containsMouse ? Theme.surfaceHigh : "transparent"

                        // Icon= is a theme icon name or a file; missing from the theme: a glyph instead of Qt's checkerboard
                        IconImage {
                            id: icon

                            readonly property string name: row.modelData.icon

                            anchors.verticalCenter: parent.verticalCenter
                            x: 10
                            implicitSize: 30
                            asynchronous: true
                            source: name.startsWith("/") ? "file://" + name : Quickshell.iconPath(name, true)
                            visible: source != ""
                        }

                        StyledText {
                            anchors.centerIn: icon
                            text: Icons.application
                            font.family: Theme.iconFont
                            font.pixelSize: 26
                            color: row.current ? Theme.textOnPrimaryContainer : Theme.textVariant
                            visible: !icon.visible
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 12

                            StyledText {
                                width: parent.width
                                text: row.modelData.name
                                elide: Text.ElideRight
                                color: row.current ? Theme.textOnPrimaryContainer : Theme.text
                            }

                            StyledText {
                                width: parent.width
                                text: row.modelData.genericName || row.modelData.comment
                                visible: text !== ""
                                elide: Text.ElideRight
                                font.pixelSize: Theme.fontSize - 2
                                color: row.current ? Theme.textOnPrimaryContainer : Theme.textVariant
                            }
                        }

                        MouseArea {
                            id: rowMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }

                StyledText {
                    x: 12
                    height: 40
                    text: "Ничего не найдено"
                    color: Theme.textVariant
                    visible: list.count === 0
                }
            }
        }
    }
}
