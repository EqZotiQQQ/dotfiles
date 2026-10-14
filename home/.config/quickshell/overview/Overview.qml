import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

// Workspace overview (SUPER+Tab: `qs ipc call overview toggle`): every monitor shows a grid of its workspaces,
// empty ones too (workspace rules: 1-9 DP-2, 10-18 DP-1), with live window previews; captured only while open.
// Click a window: focus it, click a workspace: go there. Esc, the key again or a click beside the grid closes.
Scope {
    id: root

    property bool open: false
    // monitor name -> workspace ids bound to it by workspace rules (`hyprctl workspacerules -j`)
    property var rules: ({})

    function toggle() {
        if (!open) {
            // window geometry (lastIpcObject) is not streamed with events
            Hyprland.refreshToplevels();
            rulesProc.running = true;
        }
        open = !open;
    }

    function go(dispatcher) {
        Hyprland.dispatch(dispatcher);
        open = false;
    }

    // qs ipc call overview toggle
    IpcHandler {
        target: "overview"

        function toggle(): void {
            root.toggle();
        }
    }

    Process {
        id: rulesProc

        running: true
        command: ["hyprctl", "workspacerules", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const rules = {};
                for (const r of JSON.parse(text)) {
                    const id = Number(r.workspaceString);
                    if (r.monitor && Number.isInteger(id) && id > 0)
                        rules[r.monitor] = (rules[r.monitor] ?? []).concat(id);
                }
                root.rules = rules;
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property ShellScreen modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            // workspaces now on this monitor, plus the empty ones its rules would create here
            readonly property var ids: {
                const all = Hyprland.workspaces.values.filter(w => w.id > 0);
                const ids = all.filter(w => w.monitor === monitor).map(w => w.id);
                for (const id of root.rules[modelData.name] ?? [])
                    if (!all.some(w => w.id === id))
                        ids.push(id);
                return ids.sort((a, b) => a - b);
            }
            readonly property int columns: Math.max(1, Math.ceil(Math.sqrt(ids.length)))
            readonly property int rows: Math.max(1, Math.ceil(ids.length / columns))
            readonly property int gap: 24
            // screen -> tile: the grid takes up to 80% of the screen
            readonly property real zoom: Math.min((width * 0.8 - (columns - 1) * gap) / columns / width, (height * 0.8 - (rows - 1) * gap) / rows / height)

            screen: modelData
            visible: root.open
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }
            color: Theme.alpha(Theme.surface, 0.6)
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-overview"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            onVisibleChanged: if (visible) keys.forceActiveFocus()

            Item {
                id: keys

                anchors.fill: parent
                Keys.onEscapePressed: root.open = false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.open = false
            }

            Grid {
                anchors.centerIn: parent
                columns: window.columns
                spacing: window.gap
                scale: root.open ? 1 : 0.94

                Behavior on scale {
                    ThemeAnim {}
                }

                Repeater {
                    model: window.ids

                    // clips windows at the screen edge to the rounded corners
                    delegate: ClippingRectangle {
                        id: tile

                        required property int modelData
                        readonly property HyprlandWorkspace workspace: Hyprland.workspaces.values.find(w => w.id === modelData) ?? null
                        readonly property bool active: workspace !== null && window.monitor?.activeWorkspace === workspace

                        width: window.modelData.width * window.zoom
                        height: window.modelData.height * window.zoom
                        radius: Theme.tileRadius
                        color: Theme.popoutPanel
                        border.width: active ? 2 : 1
                        border.color: active ? Theme.primary : tileHover.hovered ? Theme.outline : Theme.alpha(Theme.outlineVariant, 0.5)

                        HoverHandler {
                            id: tileHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.go(`hl.dsp.focus({ workspace = ${tile.modelData} })`)
                        }

                        // windows in layout coordinates, floating ones on top
                        Repeater {
                            model: ScriptModel {
                                values: Hyprland.toplevels.values.filter(t => tile.workspace && t.workspace === tile.workspace && t.lastIpcObject.at && !t.lastIpcObject.hidden).sort((a, b) => a.lastIpcObject.floating - b.lastIpcObject.floating)
                            }

                            delegate: Rectangle {
                                id: win

                                required property HyprlandToplevel modelData
                                readonly property var ipc: modelData.lastIpcObject

                                x: (ipc.at[0] - window.modelData.x) * window.zoom
                                y: (ipc.at[1] - window.modelData.y) * window.zoom
                                width: ipc.size[0] * window.zoom
                                height: ipc.size[1] * window.zoom
                                color: Theme.surfaceHigh

                                ScreencopyView {
                                    id: view

                                    anchors.fill: parent
                                    captureSource: root.open ? win.modelData.wayland : null
                                    live: true
                                }

                                // until the first frame arrives
                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: Math.min(48, parent.width / 2, parent.height / 2)
                                    asynchronous: true
                                    source: Quickshell.iconPath(DesktopEntries.heuristicLookup(win.ipc.class)?.icon || "application-x-executable", "application-x-executable")
                                    visible: !view.hasContent
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.width: 2
                                    border.color: Theme.primary
                                    visible: winMouse.containsMouse
                                }

                                MouseArea {
                                    id: winMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.go(`hl.dsp.focus({ window = "address:0x${win.modelData.address}" })`)
                                }
                            }
                        }

                        // workspace number as on the bar: 1..9 on each monitor
                        Rectangle {
                            x: 8
                            y: 8
                            width: Math.max(height, label.implicitWidth + 12)
                            height: 24
                            radius: height / 2
                            color: tile.active ? Theme.primary : Theme.surfaceHigh

                            StyledText {
                                id: label

                                anchors.centerIn: parent
                                text: (tile.modelData - 1) % 9 + 1
                                font.weight: Font.DemiBold
                                color: tile.active ? Theme.textOnPrimary : Theme.text
                            }
                        }
                    }
                }
            }
        }
    }
}
