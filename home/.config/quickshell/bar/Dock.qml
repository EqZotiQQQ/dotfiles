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

    readonly property string edge: Theme.barPosition
    readonly property bool vertical: Theme.barVertical

    function activate(app) {
        const windows = app.toplevels;
        if (windows.length === 0) {
            app.entry?.execute();
            return;
        }
        const current = windows.findIndex(t => t.activated);
        windows[(current + 1) % windows.length].activate();
    }

    width: vertical ? Theme.barSize : tiles.implicitWidth + 16
    height: vertical ? tiles.implicitHeight + 16 : Theme.barSize
    radius: Theme.islandRadius
    color: Theme.panel
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.5)

    Behavior on width {
        ThemeAnim {}
    }
    Behavior on height {
        ThemeAnim {}
    }

    Strip {
        id: tiles

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.apps

            delegate: Strip {
                id: app

                required property var modelData
                required property int index
                readonly property bool running: modelData.toplevels.length > 0
                readonly property bool focused: modelData.toplevels.some(t => t.activated)
                readonly property int distance: root.hovered < 0 ? 99 : Math.abs(root.hovered - index)

                spacing: 4

                // between pinned and unpinned apps
                Rectangle {
                    width: root.vertical ? 24 : 1
                    height: root.vertical ? 1 : 24
                    color: Theme.outlineVariant
                    visible: app.index > 0 && app.index === root.pinnedCount
                }

                Item {
                    id: slot

                    width: root.vertical ? Theme.barSize : 40
                    height: root.vertical ? 40 : Theme.barSize

                    // hovered: grows away from the screen edge
                    Rectangle {
                        property real push: app.distance === 0 ? 3 : 0

                        x: (slot.width - width) / 2 + (root.edge === "left" ? push : root.edge === "right" ? -push : 0)
                        y: (slot.height - height) / 2 + (root.edge === "top" ? push : root.edge === "bottom" ? -push : 0)
                        width: 36
                        height: 36
                        radius: Theme.tileRadius
                        color: Theme.surfaceHigh
                        transformOrigin: ({ left: Item.Left, right: Item.Right, top: Item.Top, bottom: Item.Bottom })[root.edge]
                        scale: app.distance === 0 ? 1.18 : app.distance === 1 ? 1.06 : 1

                        Behavior on scale {
                            ThemeAnim {}
                        }
                        Behavior on push {
                            ThemeAnim {}
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 26
                            asynchronous: true
                            source: Quickshell.iconPath(app.modelData.entry?.icon || "application-x-executable", "application-x-executable")
                        }
                    }

                    // running indicator on the screen-edge side, long for the focused app
                    Rectangle {
                        property real long: app.focused ? 16 : 4

                        x: root.edge === "left" ? 1 : root.edge === "right" ? slot.width - 4 : (slot.width - width) / 2
                        y: root.edge === "top" ? 1 : root.edge === "bottom" ? slot.height - 4 : (slot.height - height) / 2
                        width: root.vertical ? 3 : long
                        height: root.vertical ? long : 3
                        radius: 2
                        color: Theme.primary
                        opacity: app.running ? 1 : 0

                        Behavior on long {
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
