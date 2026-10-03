import QtQuick
import qs.common
import qs.services
import qs.bar.popouts

// Right island: status modules. Hovering a module that has a popout grows the island down into
// that popout (one shape, morphing); leaving the island closes it, a click pins it open until the
// module is clicked again.
Rectangle {
    id: root

    property string open: ""     // shown popout: cpu | temp | mem | audio | calendar | power, "" = closed
    property string pinned: ""
    property string shown: ""    // last opened popout, stays loaded while the island shrinks back
    readonly property int padding: 18

    function hover(key) {
        if (pinned === "") {
            hoverDelay.key = key;
            hoverDelay.restart();
        }
    }

    function click(key) {
        if (pinned === key) {
            pinned = "";
            open = "";
        } else {
            pinned = key;
            open = key;
        }
    }

    function close() {
        pinned = "";
        open = "";
    }

    onOpenChanged: if (open !== "") shown = open

    width: Math.max(modules.implicitWidth + 12, open !== "" && popout.item ? popout.item.preferredWidth + 2 * padding : 0)
    height: Theme.barHeight + Math.max(0, body.height)
    radius: Theme.islandRadius
    color: Theme.panel
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.5)
    clip: true

    Behavior on width {
        ThemeAnim {}
    }

    HoverHandler {
        id: hoverArea

        onHoveredChanged: hovered ? leaveDelay.stop() : leaveDelay.restart()
    }

    Timer {
        id: hoverDelay

        property string key

        interval: 120
        onTriggered: if (root.pinned === "" && hoverArea.hovered) root.open = key
    }

    Timer {
        id: leaveDelay

        interval: 350
        onTriggered: if (root.pinned === "") root.open = ""
    }

    Row {
        id: modules

        x: 6
        height: Theme.barHeight
        spacing: 2

        Chip {
            icon: Icons.cpu
            text: Cpu.usage + "%"
            widthTemplate: "100%"
            active: root.open === "cpu"
            onEntered: root.hover("cpu")
            onClicked: root.click("cpu")
        }

        Chip {
            icon: Icons.thermometer
            text: Sensors.cpuTemp + "°"
            widthTemplate: "100°"
            active: root.open === "temp"
            onEntered: root.hover("temp")
            onClicked: root.click("temp")
        }

        Chip {
            icon: Icons.memory
            text: Memory.usedPct + "%"
            widthTemplate: "100%"
            active: root.open === "mem"
            onEntered: root.hover("mem")
            onClicked: root.click("mem")
        }

        // wheel: volume, middle click: mute
        Chip {
            icon: Audio.muted ? Icons.volumeMute : Audio.volume < 0.33 ? Icons.volumeLow : Audio.volume < 0.66 ? Icons.volumeMedium : Icons.volumeHigh
            text: Math.round(Audio.volume * 100) + "%"
            widthTemplate: "100%"
            active: root.open === "audio"
            onEntered: root.hover("audio")
            onClicked: button => button === Qt.MiddleButton ? Audio.toggleMute() : root.click("audio")
            onWheel: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
        }

        Chip {
            icon: Network.iface === "" ? Icons.offline : Network.wireless ? Icons.wifi : Icons.ethernet
            text: "↓" + Network.fmt(Network.rx) + " ↑" + Network.fmt(Network.tx)
            widthTemplate: "↓10.0M ↑10.0M"
        }

        Chip {
            text: Keyboard.layout
            mono: false
        }

        Chip {
            icon: Mako.dnd ? Icons.bellOff : Icons.bell
            iconColor: Mako.dnd ? Theme.tertiary : Theme.text
            onClicked: Mako.toggle()
        }

        Chip {
            text: Qt.formatDateTime(Time.date, "HH:mm")
            mono: false
            active: root.open === "calendar"
            onEntered: root.hover("calendar")
            onClicked: root.click("calendar")

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Time.date.toLocaleDateString(Time.locale, "ddd, d MMM")
                color: root.open === "calendar" ? Theme.textOnPrimaryContainer : Theme.textVariant
            }
        }

        Chip {
            icon: Icons.power
            active: root.open === "power"
            onEntered: root.hover("power")
            onClicked: root.click("power")
        }
    }

    // The popout: the island's height follows its content
    Item {
        id: body

        y: Theme.barHeight
        width: root.width
        height: root.open !== "" && popout.item ? popout.item.implicitHeight + root.padding + 6 : 0

        Behavior on height {
            ThemeAnim {}
        }

        Loader {
            id: popout

            x: root.padding
            y: 6
            width: body.width - 2 * root.padding
            active: root.open !== "" || body.height > 0.5
            sourceComponent: ({
                    cpu: cpuPopout,
                    temp: tempPopout,
                    mem: memPopout,
                    audio: audioPopout,
                    calendar: calendarPopout,
                    power: powerPopout
                })[root.shown] ?? null
            opacity: root.open !== "" ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        Connections {
            target: popout.item
            ignoreUnknownSignals: true

            function onDone() {
                root.close();
            }
        }
    }

    Component {
        id: cpuPopout

        CpuPopout {}
    }
    Component {
        id: tempPopout

        TempPopout {}
    }
    Component {
        id: memPopout

        MemoryPopout {}
    }
    Component {
        id: audioPopout

        AudioPopout {}
    }
    Component {
        id: calendarPopout

        CalendarPopout {}
    }
    Component {
        id: powerPopout

        PowerPopout {}
    }
}
