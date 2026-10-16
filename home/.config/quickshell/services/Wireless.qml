pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.common

// Wireless mice and keyboards: scripts/wireless (hidraw: Logitech HID++, Razer) every 2 minutes, every 5 s while
// a popout watches, and meanwhile the polling rate actually seen on mouse input (wireless --measure).
// Paired Bluetooth devices the script doesn't report (not connected, or neither Logitech nor Razer) come from bluez.
// A battery off the charger dropping to 15% and to 5% pops a notification, once each until it charges
Singleton {
    id: root

    property var devices: []      // scripts/wireless: [{ id, name, kind, link, online, battery, charging, ... }]
    property var measured: ({})   // id -> Hz seen on its input events
    property int watchers: 0      // popouts showing them
    readonly property var bluetooth: Bluetooth.devices.values.filter(d => d.paired && !devices.some(w => w.address === d.address.toLowerCase()))
    // the least battery, the last known one of a device asleep too: the chip
    readonly property var weakest: devices.filter(d => d.battery != null).reduce((w, d) => !w || d.battery < w.battery ? d : w, null)

    property string _text: ""
    property var _warned: ({})    // id -> the lowest level already notified

    function icon(kind) {
        return kind === "mouse" ? Icons.mouse : kind === "keyboard" ? Icons.keyboard : Icons.bluetooth;
    }

    // "≈ 1 д 4 ч", "≈ 14 ч", "≈ 40 мин"
    function duration(hours) {
        const h = Math.round(hours);
        return "≈ " + (hours < 1 ? Math.max(1, Math.round(hours * 60)) + " мин" : h >= 24 ? Math.floor(h / 24) + " д " + h % 24 + " ч" : h + " ч");
    }

    function ago(seen) {
        const s = Date.now() / 1000 - seen;
        return s < 120 ? "только что" : s < 7200 ? Math.round(s / 60) + " мин назад" : s < 172800 ? Math.round(s / 3600) + " ч назад" : Math.round(s / 86400) + " д назад";
    }

    function warn() {
        for (const d of devices) {
            if (!d.online || d.battery == null)
                continue;
            if (d.charging) {
                delete _warned[d.id];
                continue;
            }
            const level = d.battery <= 5 ? 5 : d.battery <= 15 ? 15 : 100;
            if (level < (_warned[d.id] ?? 100)) {
                _warned[d.id] = level;
                Quickshell.execDetached(["notify-send", "-a", "Устройства", "-u", level === 5 ? "critical" : "normal", "Низкий заряд: " + d.name, d.battery + "%"]);
            }
        }
    }

    onWatchersChanged: if (watchers > 0) list.running = true

    Process {
        id: list
        command: [Quickshell.shellDir + "/scripts/wireless"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text === root._text)
                    return;
                try {
                    root.devices = JSON.parse(this.text);
                    root._text = this.text;
                    root.warn();
                } catch (e) {
                    console.warn("wireless:", e);
                }
            }
        }
    }

    Timer {
        interval: root.watchers > 0 ? 5000 : 120000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: list.running = true
    }

    // setpriv: the measurement dies with qs
    Process {
        running: root.watchers > 0
        command: ["setpriv", "--pdeathsig", "TERM", "--", Quickshell.shellDir + "/scripts/wireless", "--measure"]
        stdout: SplitParser {
            onRead: line => {
                const m = JSON.parse(line);
                root.measured = Object.assign({}, root.measured, { [m.id]: m.hz });
            }
        }
    }
}
