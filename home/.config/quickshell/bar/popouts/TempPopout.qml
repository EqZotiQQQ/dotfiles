import QtQuick
import qs.common
import qs.services

// Every hwmon temperature sensor
Column {
    readonly property int preferredWidth: 360   // the island grows at least this wide
    spacing: 8

    Component.onCompleted: Sensors.watchers++
    Component.onDestruction: Sensors.watchers--

    Header {
        width: parent.width
        title: "Температура"
        detail: "CPU " + Sensors.cpuTemp + "°C"
    }

    Repeater {
        model: Sensors.all

        delegate: Item {
            required property var modelData

            width: parent.width
            height: 20

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: parent.modelData.device + " · " + parent.modelData.label
                color: Theme.textVariant
            }

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: parent.modelData.temp + "°C"
                font.family: Theme.monoFont
                color: parent.modelData.temp >= 80 ? Theme.error : parent.modelData.temp >= 60 ? Theme.tertiary : Theme.text
            }
        }
    }
}
