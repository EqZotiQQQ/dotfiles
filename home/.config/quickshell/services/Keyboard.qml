pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Active keyboard layout as two letters ("EN", "RU"): read once, then follows Hyprland's activelayout event
Singleton {
    id: root

    property string layout: ""

    function short(name) {
        return name.slice(0, 2).toUpperCase();
    }

    Process {
        running: true
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const kbs = JSON.parse(this.text).keyboards;
                    const kb = kbs.find(k => k.main) ?? kbs[kbs.length - 1];
                    if (kb)
                        root.layout = root.short(kb.active_keymap);
                } catch (e) {
                    console.warn("Keyboard:", e);
                }
            }
        }
    }

    // data: "<keyboard>,<layout name>"
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.layout = root.short(event.data.slice(event.data.indexOf(",") + 1));
        }
    }
}
