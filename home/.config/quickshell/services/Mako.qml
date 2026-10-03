pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// mako's do-not-disturb mode (toggled by ~/.local/bin/mako-dnd)
Singleton {
    id: root

    property bool dnd: false

    function toggle() {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/mako-dnd"]);
        refreshSoon.restart();
    }

    Process {
        id: mode
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.dnd = this.text.split("\n").includes("do-not-disturb")
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mode.running = true
    }

    Timer {
        id: refreshSoon
        interval: 300
        onTriggered: mode.running = true
    }
}
