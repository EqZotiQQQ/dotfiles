pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU temperature (first hwmon with a CPU driver: hwmonN numbering changes between boots);
// all sensors (scripts/sensors) while a popout watches them
Singleton {
    id: root

    property int cpuTemp: 0    // °C
    property var all: []       // [{ device, label, temp }]
    property int watchers: 0   // popouts showing `all`

    property string _cpuInput: ""

    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do echo \"$h $(cat $h/name)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const drivers = ["k10temp", "coretemp", "zenpower", "cpu_thermal"];
                const hit = this.text.split("\n").map(l => l.split(" ")).find(f => drivers.includes(f[1]));
                if (hit)
                    root._cpuInput = hit[0] + "/temp1_input";
            }
        }
    }

    FileView {
        id: cpuFile
        path: root._cpuInput
        onLoaded: root.cpuTemp = Math.round(parseInt(text()) / 1000)
    }

    Timer {
        interval: 2000
        running: root._cpuInput !== ""
        repeat: true
        onTriggered: cpuFile.reload()
    }

    Process {
        id: allProc
        command: [Quickshell.shellDir + "/scripts/sensors"]
        stdout: StdioCollector {
            onStreamFinished: root.all = this.text.split("\n").filter(l => l).map(l => {
                const f = l.split("\t");
                return { device: f[0], label: f[1], temp: Number(f[2]) };
            })
        }
    }

    Timer {
        interval: 2000
        running: root.watchers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: allProc.running = true
    }
}
