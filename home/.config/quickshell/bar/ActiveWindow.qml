import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common

// Icon + title of the focused window if it's on this monitor, else of a window on this monitor's workspace
Row {
    id: root

    required property HyprlandMonitor monitor
    readonly property HyprlandToplevel toplevel: {
        const active = Hyprland.activeToplevel;
        if (active && active.monitor === monitor)
            return active;
        return monitor?.activeWorkspace?.toplevels.values[0] ?? null;
    }
    readonly property string appId: toplevel?.wayland?.appId ?? toplevel?.lastIpcObject?.class ?? ""

    visible: toplevel !== null
    spacing: 8

    IconImage {
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 18
        asynchronous: true
        source: root.toplevel ? Quickshell.iconPath(DesktopEntries.heuristicLookup(root.appId)?.icon || "application-x-executable", "application-x-executable") : ""
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 320)
        text: root.toplevel?.title ?? ""
        elide: Text.ElideRight
        color: Theme.textVariant
    }
}
