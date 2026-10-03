import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

// Pinned apps, then running unpinned ones. Click: launch, focus, or cycle through the app's windows.
Rectangle {
    id: root

    // desktop entry ids: /usr/share/applications/<id>.desktop
    property list<string> pinned: ["kitty", "google-chrome", "obsidian", "code", "org.kde.dolphin"]

    // [{ entry, appId, toplevels }]: pinned first, windows grouped by their desktop entry
    readonly property var apps: {
        const result = pinned.map(id => ({ entry: DesktopEntries.byId(id), appId: id, toplevels: [] })).filter(a => a.entry);
        for (const t of ToplevelManager.toplevels.values) {
            const entry = DesktopEntries.heuristicLookup(t.appId);
            let app = result.find(a => entry ? a.entry === entry : a.appId === t.appId);
            if (!app) {
                app = { entry: entry, appId: t.appId, toplevels: [] };
                result.push(app);
            }
            app.toplevels.push(t);
        }
        return result;
    }
    readonly property int pinnedCount: apps.filter(a => pinned.includes(a.appId)).length
    property int hovered: -1

    function activate(app) {
        const windows = app.toplevels;
        if (windows.length === 0) {
            app.entry?.execute();
            return;
        }
        const current = windows.findIndex(t => t.activated);
        windows[(current + 1) % windows.length].activate();
    }

    width: tiles.implicitWidth + 16
    height: Theme.barHeight
    radius: Theme.islandRadius
    color: Theme.panel
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.5)

    Behavior on width {
        ThemeAnim {}
    }

    Row {
        id: tiles

        x: 8
        height: parent.height
        spacing: 4

        Repeater {
            model: root.apps

            delegate: Row {
                id: app

                required property var modelData
                required property int index
                readonly property bool running: modelData.toplevels.length > 0
                readonly property bool focused: modelData.toplevels.some(t => t.activated)
                readonly property int distance: root.hovered < 0 ? 99 : Math.abs(root.hovered - index)

                height: parent.height
                spacing: 4

                // between pinned and unpinned apps
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 24
                    color: Theme.outlineVariant
                    visible: app.index > 0 && app.index === root.pinnedCount
                }

                Item {
                    width: 40
                    height: parent.height

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 5 + (app.distance === 0 ? 3 : 0)
                        width: 36
                        height: 36
                        radius: Theme.tileRadius
                        color: Theme.surfaceHigh
                        transformOrigin: Item.Top
                        scale: app.distance === 0 ? 1.18 : app.distance === 1 ? 1.06 : 1

                        Behavior on scale {
                            ThemeAnim {}
                        }
                        Behavior on y {
                            ThemeAnim {}
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 26
                            asynchronous: true
                            source: Quickshell.iconPath(app.modelData.entry?.icon || "application-x-executable", "application-x-executable")
                        }
                    }

                    // running indicator, wide for the focused app
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: app.focused ? 16 : 4
                        height: 3
                        radius: 2
                        color: Theme.primary
                        opacity: app.running ? 1 : 0

                        Behavior on width {
                            ThemeAnim {}
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.hovered = app.index
                        onExited: if (root.hovered === app.index) root.hovered = -1
                        onClicked: root.activate(app.modelData)
                    }
                }
            }
        }
    }
}
