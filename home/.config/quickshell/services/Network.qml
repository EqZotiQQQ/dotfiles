pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Default-route interface and its download/upload speed, from /proc/net/route and /proc/net/dev
Singleton {
    id: root

    property string iface: ""
    readonly property bool wireless: iface.startsWith("wl")
    property real rx: 0   // bytes/s
    property real tx: 0

    property var _last: null

    function fmt(bytes) {
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + "M";
        if (bytes >= 1024)
            return Math.round(bytes / 1024) + "K";
        return Math.round(bytes) + "B";
    }

    FileView {
        id: route
        path: "/proc/net/route"
        onLoaded: {
            const def = text().split("\n").slice(1).map(l => l.trim().split(/\s+/)).find(f => f[1] === "00000000");
            root.iface = def ? def[0] : "";
        }
    }

    FileView {
        id: dev
        path: "/proc/net/dev"
        onLoaded: {
            const line = text().split("\n").find(l => l.trim().startsWith(root.iface + ":"));
            if (!root.iface || !line) {
                root.rx = 0;
                root.tx = 0;
                root._last = null;
                return;
            }
            const f = line.split(":")[1].trim().split(/\s+/).map(Number);
            const now = Date.now();
            const last = root._last;
            if (last && last.iface === root.iface) {
                const dt = (now - last.time) / 1000;
                root.rx = Math.max(0, (f[0] - last.rx) / dt);
                root.tx = Math.max(0, (f[8] - last.tx) / dt);
            }
            root._last = { iface: root.iface, time: now, rx: f[0], tx: f[8] };
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            route.reload();
            dev.reload();
        }
    }
}
