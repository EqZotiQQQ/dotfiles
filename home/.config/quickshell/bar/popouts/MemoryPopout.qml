import QtQuick
import qs.common
import qs.services

// RAM / cache / swap + top processes by memory
Column {
    readonly property int preferredWidth: 400   // the island grows at least this wide
    spacing: 12

    Component.onCompleted: Memory.watchers++
    Component.onDestruction: Memory.watchers--

    Header {
        width: parent.width
        title: "Память"
        detail: Memory.fmt(Memory.used) + " / " + Memory.fmt(Memory.total)
    }

    Meter {
        width: parent.width
        label: "RAM"
        value: Memory.total > 0 ? Memory.used / Memory.total : 0
        detail: Memory.usedPct + "%"
    }

    Meter {
        width: parent.width
        label: "Кэш"
        value: Memory.total > 0 ? Memory.cached / Memory.total : 0
        detail: Memory.fmt(Memory.cached)
        barColor: Theme.secondary
    }

    Meter {
        width: parent.width
        visible: Memory.swapTotal > 0
        label: "Swap"
        value: Memory.swapTotal > 0 ? Memory.swapUsed / Memory.swapTotal : 0
        detail: Memory.fmt(Memory.swapUsed) + " / " + Memory.fmt(Memory.swapTotal)
        barColor: Theme.tertiary
    }

    StyledText {
        text: "Топ по памяти"
        font.pixelSize: 12
        color: Theme.textVariant
    }

    Repeater {
        model: Memory.top

        delegate: ProcRow {
            required property var modelData

            width: parent.width
            name: modelData.name
            value: Memory.fmt(modelData.value)
        }
    }
}
