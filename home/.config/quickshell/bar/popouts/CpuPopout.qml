import QtQuick
import qs.common
import qs.services

// Load per logical core + top processes by CPU
Column {
    readonly property int preferredWidth: 440   // the island grows at least this wide
    spacing: 14

    Component.onCompleted: Cpu.watchers++
    Component.onDestruction: Cpu.watchers--

    Header {
        width: parent.width
        title: "Процессор"
        detail: Cpu.usage + "% · " + Sensors.cpuTemp + "°C"
    }

    Row {
        width: parent.width
        spacing: 22

        Column {
            id: cores

            spacing: 6

            Row {
                height: 80
                spacing: 4

                Repeater {
                    model: Cpu.cores.length

                    delegate: Rectangle {
                        required property int index
                        readonly property int load: Cpu.cores[index] ?? 0

                        width: 10
                        height: 80
                        radius: 5
                        color: Theme.surfaceHigh

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: Math.max(width, parent.height * parent.load / 100)
                            radius: 5
                            color: parent.load > 60 ? Theme.primary : Theme.secondary

                            Behavior on height {
                                ThemeAnim {}
                            }
                        }
                    }
                }
            }

            StyledText {
                text: Cpu.cores.length + " потоков"
                font.pixelSize: 12
                color: Theme.textVariant
            }
        }

        Column {
            width: parent.width - cores.width - parent.spacing
            spacing: 6

            StyledText {
                text: "Топ по CPU"
                font.pixelSize: 12
                color: Theme.textVariant
            }

            Repeater {
                model: Cpu.top

                delegate: ProcRow {
                    required property var modelData

                    width: parent.width
                    name: modelData.name
                    value: modelData.value.toFixed(1) + "%"
                }
            }
        }
    }
}
