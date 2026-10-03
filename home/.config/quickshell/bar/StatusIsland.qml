import QtQuick
import QtQuick.Shapes
import qs.common
import qs.services
import qs.bar.popouts

// Status island at the end of the bar. Hovering a module that has a popout slides a panel out of the
// island, away from the screen edge and level with that module: island and panel are one shape with
// concave joints, morphing as the popout opens, moves or changes. Leaving the island closes it,
// a click pins it open until the module is clicked again.
//
// Geometry is worked out in an edge frame, u = away from the screen edge, v = along it, then mapped
// to x/y for the bar's edge (mx/my): one shape for all four positions.
Item {
    id: root

    property string open: ""      // shown popout: cpu | temp | mem | audio | calendar | power, "" = closed
    property string pinned: ""
    property string shown: ""     // last opened popout, stays loaded while the panel slides back
    property Item anchorChip: null // the module the panel lines up with

    readonly property string edge: Theme.barPosition
    readonly property bool vertical: Theme.barVertical
    readonly property int padding: 18
    readonly property int bar: Theme.barSize
    readonly property int corner: Theme.islandRadius
    readonly property int fillet: Theme.tileRadius

    // popout content size on screen, kept while the panel slides back and unloads
    property real contentWidth: 0
    property real contentHeight: 0
    // panel in the edge frame (animated): depth slides it out, offset follows the module
    property real depth: open !== "" && popout.item ? (vertical ? contentWidth : contentHeight) : 0
    property real extent: vertical ? contentHeight : contentWidth
    readonly property real modulesLength: vertical ? modules.implicitHeight : modules.implicitWidth
    readonly property real length: Math.max(modulesLength + 16, extent + 2 * (corner + fillet))
    property real offset: {
        const chip = anchorChip;
        const center = !chip ? length / 2 : vertical ? modules.y + chip.y + chip.height / 2 : modules.x + chip.x + chip.width / 2;
        const lowest = corner + fillet;
        return Math.max(lowest, Math.min(center - extent / 2, length - lowest - extent));
    }

    // input regions for the bar's mask
    readonly property Item island: islandArea
    readonly property Item panel: panelArea

    // edge frame -> item coordinates
    function mx(u, v) {
        return edge === "left" ? u : edge === "right" ? width - u : v;
    }

    function my(u, v) {
        return edge === "top" ? u : edge === "bottom" ? height - u : v;
    }

    function box(u, v, du, dv) {
        const x0 = mx(u, v), x1 = mx(u + du, v + dv), y0 = my(u, v), y1 = my(u + du, v + dv);
        return Qt.rect(Math.min(x0, x1), Math.min(y0, y1), Math.abs(x1 - x0), Math.abs(y1 - y0));
    }

    function hover(key, chip) {
        if (pinned === "") {
            hoverDelay.key = key;
            hoverDelay.chip = chip;
            hoverDelay.restart();
        }
    }

    function click(key, chip) {
        if (pinned === key) {
            close();
        } else {
            pinned = key;
            anchorChip = chip;
            open = key;
        }
    }

    function close() {
        pinned = "";
        open = "";
    }

    onOpenChanged: if (open !== "") shown = open

    width: vertical ? bar + depth : length
    height: vertical ? length : bar + depth

    Behavior on depth {
        ThemeAnim {}
    }
    Behavior on extent {
        ThemeAnim {}
    }
    Behavior on offset {
        ThemeAnim {}
    }

    Binding {
        target: root
        property: "contentWidth"
        value: (popout.item?.preferredWidth ?? 0) + 2 * root.padding
        when: popout.item !== null
        restoreMode: Binding.RestoreNone
    }
    Binding {
        target: root
        property: "contentHeight"
        value: (popout.item?.implicitHeight ?? 0) + 2 * root.padding
        when: popout.item !== null
        restoreMode: Binding.RestoreNone
    }

    HoverHandler {
        id: hoverArea

        onHoveredChanged: hovered ? leaveDelay.stop() : leaveDelay.restart()
    }

    Timer {
        id: hoverDelay

        property string key
        property Item chip

        interval: 120
        onTriggered: {
            if (root.pinned === "" && hoverArea.hovered) {
                root.anchorChip = chip;
                root.open = key;
            }
        }
    }

    Timer {
        id: leaveDelay

        interval: 350
        onTriggered: if (root.pinned === "") root.open = ""
    }

    // Island + panel outline, in the edge frame; mirrored frames (right, top) turn the arcs around
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: outline

            readonly property real w: root.bar
            readonly property real h: root.length
            readonly property real r: Math.min(root.corner, w / 2)
            readonly property real top: root.offset
            readonly property real bottom: root.offset + root.extent
            readonly property real out: w + root.depth
            readonly property real pr: Math.min(root.corner, root.depth / 2, root.extent / 2)
            readonly property real f: Math.min(root.fillet, root.depth / 2)
            readonly property bool mirrored: root.edge === "right" || root.edge === "top"
            readonly property int turn: mirrored ? PathArc.Counterclockwise : PathArc.Clockwise
            readonly property int back: mirrored ? PathArc.Clockwise : PathArc.Counterclockwise

            fillColor: root.open !== "" ? Theme.popoutPanel : Theme.panel
            strokeColor: Theme.alpha(Theme.outlineVariant, 0.5)
            strokeWidth: 1
            startX: root.mx(outline.r, 0)
            startY: root.my(outline.r, 0)

            Behavior on fillColor {
                ColorAnimation {
                    duration: 200
                }
            }

            PathArc { x: root.mx(outline.w, outline.r); y: root.my(outline.w, outline.r); radiusX: outline.r; radiusY: outline.r; direction: outline.turn }
            PathLine { x: root.mx(outline.w, outline.top - outline.f); y: root.my(outline.w, outline.top - outline.f) }
            PathArc { x: root.mx(outline.w + outline.f, outline.top); y: root.my(outline.w + outline.f, outline.top); radiusX: outline.f; radiusY: outline.f; direction: outline.back }
            PathLine { x: root.mx(outline.out - outline.pr, outline.top); y: root.my(outline.out - outline.pr, outline.top) }
            PathArc { x: root.mx(outline.out, outline.top + outline.pr); y: root.my(outline.out, outline.top + outline.pr); radiusX: outline.pr; radiusY: outline.pr; direction: outline.turn }
            PathLine { x: root.mx(outline.out, outline.bottom - outline.pr); y: root.my(outline.out, outline.bottom - outline.pr) }
            PathArc { x: root.mx(outline.out - outline.pr, outline.bottom); y: root.my(outline.out - outline.pr, outline.bottom); radiusX: outline.pr; radiusY: outline.pr; direction: outline.turn }
            PathLine { x: root.mx(outline.w + outline.f, outline.bottom); y: root.my(outline.w + outline.f, outline.bottom) }
            PathArc { x: root.mx(outline.w, outline.bottom + outline.f); y: root.my(outline.w, outline.bottom + outline.f); radiusX: outline.f; radiusY: outline.f; direction: outline.back }
            PathLine { x: root.mx(outline.w, outline.h - outline.r); y: root.my(outline.w, outline.h - outline.r) }
            PathArc { x: root.mx(outline.w - outline.r, outline.h); y: root.my(outline.w - outline.r, outline.h); radiusX: outline.r; radiusY: outline.r; direction: outline.turn }
            PathLine { x: root.mx(outline.r, outline.h); y: root.my(outline.r, outline.h) }
            PathArc { x: root.mx(0, outline.h - outline.r); y: root.my(0, outline.h - outline.r); radiusX: outline.r; radiusY: outline.r; direction: outline.turn }
            PathLine { x: root.mx(0, outline.r); y: root.my(0, outline.r) }
            PathArc { x: root.mx(outline.r, 0); y: root.my(outline.r, 0); radiusX: outline.r; radiusY: outline.r; direction: outline.turn }
        }
    }

    Item {
        id: islandArea

        readonly property rect area: root.box(0, 0, root.bar, root.length)

        x: area.x
        y: area.y
        width: area.width
        height: area.height
    }

    Strip {
        id: modules

        // centered across the bar, from the island's start along it
        readonly property real across: root.vertical ? implicitWidth : implicitHeight
        readonly property real along: root.vertical ? implicitHeight : implicitWidth
        readonly property rect area: root.box(root.bar / 2 - across / 2, 8, across, along)

        x: area.x
        y: area.y
        spacing: 2

        Chip {
            id: cpu

            icon: Icons.cpu
            text: Cpu.usage + "%"
            widthTemplate: "100%"
            active: root.open === "cpu"
            onEntered: root.hover("cpu", cpu)
            onClicked: root.click("cpu", cpu)
        }

        Chip {
            id: temp

            icon: Icons.thermometer
            text: Sensors.cpuTemp + "°"
            widthTemplate: "100°"
            active: root.open === "temp"
            onEntered: root.hover("temp", temp)
            onClicked: root.click("temp", temp)
        }

        Chip {
            id: mem

            icon: Icons.memory
            text: Memory.usedPct + "%"
            widthTemplate: "100%"
            active: root.open === "mem"
            onEntered: root.hover("mem", mem)
            onClicked: root.click("mem", mem)
        }

        // wheel: volume, middle click: mute
        Chip {
            id: audio

            icon: Audio.muted ? Icons.volumeMute : Audio.volume < 0.33 ? Icons.volumeLow : Audio.volume < 0.66 ? Icons.volumeMedium : Icons.volumeHigh
            text: Math.round(Audio.volume * 100) + "%"
            widthTemplate: "100%"
            active: root.open === "audio"
            onEntered: root.hover("audio", audio)
            onClicked: button => button === Qt.MiddleButton ? Audio.toggleMute() : root.click("audio", audio)
            onWheel: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
        }

        Chip {
            icon: Network.iface === "" ? Icons.offline : Network.wireless ? Icons.wifi : Icons.ethernet
            text: "↓" + Network.fmt(Network.rx) + (root.vertical ? "\n↑" : " ↑") + Network.fmt(Network.tx)
            textSize: root.vertical ? 10 : Theme.fontSize
            widthTemplate: "↓10.0M ↑10.0M"
        }

        Chip {
            text: Keyboard.layout
            mono: false
            textSize: root.vertical ? 12 : Theme.fontSize
        }

        Chip {
            icon: Mako.dnd ? Icons.bellOff : Icons.bell
            iconColor: Mako.dnd ? Theme.tertiary : Theme.text
            onClicked: Mako.toggle()
        }

        // vertical bar: hours over minutes; horizontal: time + date. Hover: calendar
        Chip {
            id: clock

            text: Qt.formatDateTime(Time.date, root.vertical ? "HH\nmm" : "HH:mm")
            note: Time.date.toLocaleDateString(Time.locale, "ddd, d MMM")
            mono: false
            textSize: root.vertical ? 14 : Theme.fontSize
            active: root.open === "calendar"
            onEntered: root.hover("calendar", clock)
            onClicked: root.click("calendar", clock)
        }

        Chip {
            id: power

            icon: Icons.power
            active: root.open === "power"
            onEntered: root.hover("power", power)
            onClicked: root.click("power", power)
        }
    }

    // The popout, clipped to the sliding panel
    Item {
        id: panelArea

        readonly property rect area: root.box(root.bar, root.offset, root.depth, root.extent)

        x: area.x
        y: area.y
        width: area.width
        height: area.height
        clip: true

        Loader {
            id: popout

            x: root.padding
            y: root.padding
            width: item?.preferredWidth ?? 0
            active: root.open !== "" || root.depth > 0.5
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
