pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

// mako: do-not-disturb mode (toggled by ~/.local/bin/mako-dnd), notifications and their history.
// Re-read when mako signals a change of its D-Bus properties (modes, notifications): no polling.
// Also regenerates mako's colors (~/.local/bin/mako-theme) whenever theme.json changes
Singleton {
    id: root

    readonly property string bin: Quickshell.env("HOME") + "/.local/bin/"

    property bool dnd: false
    // [{ id, app_name, app_icon, desktop_entry, summary, body, urgency, actions, live }], newest first
    property var notifications: []   // live: on screen, or held back by do-not-disturb
    property var history: []         // expired or dismissed
    readonly property var all: notifications.concat(history)
    property int seenId: 0           // newest notification the notification center has shown
    readonly property int unread: all.filter(n => n.id > seenId).length

    function toggle() {
        Quickshell.execDetached([bin + "mako-dnd"]);
    }

    function dismiss(id) {
        Quickshell.execDetached(["makoctl", "dismiss", "-n", String(id)]);
    }

    function invoke(id) {
        Quickshell.execDetached(["makoctl", "invoke", "-n", String(id)]);
    }

    // mako brings back only the most recent one
    function restore() {
        Quickshell.execDetached(["makoctl", "restore"]);
    }

    function markSeen() {
        seenId = all.reduce((newest, n) => Math.max(newest, n.id), seenId);
    }

    // `makoctl list|history -j`; empty while mako isn't running
    function parse(text, live) {
        try {
            return JSON.parse(text).map(n => Object.assign(n, { live: live })).sort((a, b) => b.id - a.id);
        } catch (e) {
            return [];
        }
    }

    Process {
        id: modes
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.dnd = this.text.split("\n").includes("do-not-disturb")
        }
    }

    Process {
        id: list
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.notifications = root.parse(this.text, true)
        }
    }

    Process {
        id: hist
        command: ["makoctl", "history", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.history = root.parse(this.text, false)
        }
    }

    // one line per message; mako emits PropertiesChanged on every new or closed notification and mode change.
    // setpriv: the monitor gets SIGTERM when qs dies, instead of living on as an orphan
    Process {
        running: true
        command: ["setpriv", "--pdeathsig", "TERM", "--", "dbus-monitor", "--session", "--profile", "type='signal',path='/fr/emersion/Mako',member='PropertiesChanged'"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("PropertiesChanged"))
                    refresh.restart();
            }
        }
    }

    // the first read, then one per burst of changes
    Timer {
        id: refresh
        interval: 50
        running: true
        onTriggered: {
            modes.running = true;
            list.running = true;
            hist.running = true;
        }
    }

    Connections {
        target: Theme

        function onJsonChanged() {
            Quickshell.execDetached([root.bin + "mako-theme"]);
        }
    }
}
