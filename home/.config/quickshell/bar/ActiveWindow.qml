import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common

// Icon (+ title on a horizontal bar) of the focused window if it's on this monitor's workspace (or its
// special one), else of a window on that workspace. Checked by workspace, not monitor: on an empty workspace
// Hyprland reports "no active window", Quickshell ignores that and keeps the last one in activeToplevel
Row {
    id: root

    required property HyprlandMonitor monitor
    readonly property HyprlandToplevel toplevel: {
        const workspace = monitor?.activeWorkspace ?? null;
        const active = Hyprland.activeToplevel;
        const special = active?.monitor === monitor && (active.workspace?.name.startsWith("special:") ?? false);
        if (active && (active.workspace === workspace || special))
            return active;
        return workspace?.toplevels.values[0] ?? null;
    }
    readonly property string appId: toplevel?.wayland?.appId ?? toplevel?.lastIpcObject?.class ?? ""

    visible: toplevel !== null
    spacing: 8

    IconImage {
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: Theme.barVertical ? 22 : 18
        asynchronous: true
        source: root.toplevel ? Quickshell.iconPath(DesktopEntries.heuristicLookup(root.appId)?.icon || "application-x-executable", "application-x-executable") : ""
    }

    // a vertical bar is too narrow for it
    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: !Theme.barVertical
        width: Math.min(implicitWidth, 320)
        text: root.toplevel?.title ?? ""
        elide: Text.ElideRight
        color: Theme.textVariant
    }
}
