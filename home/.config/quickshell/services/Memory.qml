pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// RAM / cache / swap from /proc/meminfo (KiB); top processes by RSS while a popout watches them
Singleton {
    id: root

    property real total: 0
    property real used: 0
    property real cached: 0
    property real swapTotal: 0
    property real swapUsed: 0
    readonly property int usedPct: total > 0 ? Math.round(100 * used / total) : 0

    property var top: []       // [{ name, value }], value = RSS KiB
    property int watchers: 0   // popouts showing `top`

    function fmt(kib) {
        return kib >= 1048576 ? (kib / 1048576).toFixed(1) + "G" : Math.round(kib / 1024) + "M";
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const m = {};
            for (const line of text().split("\n")) {
                const kv = line.split(":");
                if (kv.length === 2)
                    m[kv[0]] = parseInt(kv[1]);
            }
            root.total = m.MemTotal;
            root.used = m.MemTotal - m.MemAvailable;
            root.cached = (m.Buffers ?? 0) + (m.Cached ?? 0);
            root.swapTotal = m.SwapTotal;
            root.swapUsed = m.SwapTotal - m.SwapFree;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: meminfo.reload()
    }

    Process {
        id: topProc
        command: ["sh", "-c", "ps -eo rss=,comm= --sort=-rss | head -5"]
        environment: ({ LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: root.top = this.text.split("\n").filter(l => l.trim()).map(l => {
                const m = l.trim().match(/^(\d+)\s+(.*)$/);
                return { name: m[2], value: Number(m[1]) };
            })
        }
    }

    Timer {
        interval: 3000
        running: root.watchers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: topProc.running = true
    }
}
