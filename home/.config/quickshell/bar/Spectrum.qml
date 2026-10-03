import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

// spectrum (~/my_projects/spectrum, audio visualizer) as a strip behind the bar of one screen: same edge
// as the bar, thickness and colors from the theme; restarted whenever one of those changes.
// It's a layer-shell surface on layer "background": started after hyprpaper, it's drawn above the wallpaper.
Scope {
    id: root

    required property var screen

    readonly property string binary: Quickshell.env("HOME") + "/my_projects/spectrum/build/spectrum"
    readonly property string edge: Theme.barPosition
    // setpriv: spectrum gets SIGTERM when qs dies (killed, crashed), instead of living on as an orphan
    readonly property var command: ["setpriv", "--pdeathsig", "TERM", "--", root.binary, "wayland",
        "--render.window.layer_shell.output=" + screen.name,
        "--render.window.layer_shell.layer=background",
        "--render.window.layer_shell.anchor=" + edge,
        "--render.window." + (Theme.barVertical ? "width" : "height") + "=" + Theme.spectrumSize,
        "--render.orientation=" + ({ top: "down", bottom: "up", left: "right", right: "left" })[edge],   // away from the edge
        "--render.colors.palette=custom",
        "--render.colors.custom=" + JSON.stringify(Theme.spectrumColors)]
    readonly property string key: JSON.stringify(command)   // changes only when the arguments do
    property bool started: false

    onKeyChanged: {
        if (started) {
            proc.running = false;
            proc.running = true;
        }
    }

    // config reload (qs keeps running): stop this strip, the reloaded config starts its own
    Component.onDestruction: if (proc.running) proc.signal(15)

    Process {
        id: proc

        command: root.command
    }

    // let hyprpaper map its wallpaper first; skipped if spectrum isn't built
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            if (!checkBinary.running) checkBinary.running = true;
        }
    }

    Process {
        id: checkBinary

        command: ["test", "-x", root.binary]
        onExited: code => {
            if (code === 0) {
                root.started = true;
                proc.running = true;
            }
        }
    }
}
