pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU load from /proc/stat (total + per logical core); top processes while a popout watches them
Singleton {
    id: root

    property int usage: 0      // %
    property var cores: []     // % per logical core
    property var top: []       // [{ name, value }], value = %CPU
    property int watchers: 0   // popouts showing `top`

    property var _prev: []

    function parse(text) {
        const lines = text.split("\n").filter(l => l.startsWith("cpu"));
        const next = [];
        const pct = [];
        for (let i = 0; i < lines.length; i++) {
            const f = lines[i].trim().split(/\s+/).slice(1, 8).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            const p = root._prev[i];
            const dt = p ? total - p.total : 0;
            pct.push(dt > 0 ? Math.round(100 * (dt - (idle - p.idle)) / dt) : 0);
            next.push({ idle: idle, total: total });
        }
        root._prev = next;
        root.usage = pct[0] ?? 0;
        root.cores = pct.slice(1);
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: root.parse(text())
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: stat.reload()
    }

    // %CPU over a 0.5 s sample: top's first frame is an average since each process started
    Process {
        id: topProc
        command: ["sh", "-c", "top -b -n 2 -d 0.5 -o %CPU -w 512 | awk '/^top -/ { f++ } f == 2 && $1 ~ /^[0-9]+$/ && $12 != \"top\" { c = $12; for (i = 13; i <= NF; i++) c = c \" \" $i; print $9 \"\\t\" c }' | head -5"]
        environment: ({ LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: root.top = this.text.split("\n").filter(l => l).map(l => {
                const f = l.split("\t");
                return { name: f[1], value: Number(f[0]) };
            })
        }
    }

    Timer {
        interval: 2000
        running: root.watchers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: topProc.running = true
    }
}
