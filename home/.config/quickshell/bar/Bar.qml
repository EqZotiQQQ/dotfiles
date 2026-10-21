import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Bar of one screen on the edge from theme.json (bar.position): three floating islands over the
// spectrum strip (Spectrum.qml). Islands along the edge: workspaces at the start, dock in the middle,
// status at the end. The surface reaches further from the edge than the bar, so the status island can
// slide its popouts out; only the islands take input (mask), the rest of the surface is click-through.
PanelWindow {
    id: bar

    required property var modelData
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
    // the bar is on layer "top", above windows, so it steps aside for a fullscreen one (not a maximized one)
    readonly property bool fullscreen: monitor?.activeWorkspace?.toplevels.values.some(t => t.wayland?.fullscreen) ?? false

    readonly property string edge: Theme.barPosition
    readonly property bool vertical: Theme.barVertical
    readonly property int margin: Theme.barMargin

    // an island's position across the bar: `margin` away from its screen edge
    function across(size) {
        return edge === "left" || edge === "top" ? margin : (vertical ? width : height) - margin - size;
    }

    screen: modelData
    visible: !fullscreen
    anchors {
        top: edge !== "bottom"
        bottom: edge !== "top"
        left: edge !== "right"
        right: edge !== "left"
    }
    implicitWidth: margin + Theme.barSize + 560
    implicitHeight: margin + Theme.barSize + 560
    exclusiveZone: margin + Theme.barSize
    color: "transparent"
    WlrLayershell.namespace: "quickshell-bar"
    // only while a popout types into a field: Escape there gives the keyboard back
    WlrLayershell.keyboardFocus: status.keyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region {
        item: start

        Region {
            item: dock
        }
        Region {
            item: status.island
        }
        Region {
            item: status.panel
        }
    }

    // The layout of this monitor's workspace, its workspaces + the active window
    Rectangle {
        id: start

        x: bar.vertical ? bar.across(width) : bar.margin
        y: bar.vertical ? bar.margin : bar.across(height)
        width: bar.vertical ? Theme.barSize : content.implicitWidth + 16
        height: bar.vertical ? content.implicitHeight + 16 : Theme.barSize
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
            id: content

            anchors.centerIn: parent
            spacing: 8

            LayoutBox {
                monitor: bar.monitor
            }

            Workspaces {
                monitor: bar.monitor
            }

            Rectangle {
                width: bar.vertical ? 20 : 1
                height: bar.vertical ? 1 : 20
                color: Theme.outlineVariant
                visible: activeWindow.visible
            }

            ActiveWindow {
                id: activeWindow

                monitor: bar.monitor
            }
        }
    }

    // centered along the edge, but never over the other islands (small screen, many apps)
    Dock {
        id: dock

        readonly property real along: {
            const size = bar.vertical ? height : width;
            const length = bar.vertical ? bar.height : bar.width;
            const after = bar.vertical ? start.y + start.height : start.x + start.width;
            const before = bar.vertical ? status.y + status.island.y : status.x + status.island.x;
            return Math.max(after + bar.margin, Math.min((length - size) / 2, before - size - bar.margin));
        }

        x: bar.vertical ? bar.across(width) : along
        y: bar.vertical ? along : bar.across(height)
    }

    StatusIsland {
        id: status

        x: bar.vertical ? bar.across(width) : bar.width - bar.margin - width
        y: bar.vertical ? bar.height - bar.margin - height : bar.across(height)
    }
}
