import QtQuick
import qs.common

// Month grid, weeks from Monday; arrows switch months, the title goes back to the current one
Column {
    id: root

    property int offset: 0   // months from the current one
    readonly property date today: Time.date
    readonly property date month: new Date(today.getFullYear(), today.getMonth() + offset, 1)
    readonly property var days: {
        const lead = (month.getDay() + 6) % 7;   // weekday of the 1st, Monday = 0
        const count = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
        const cells = [];
        for (let i = 0; i < Math.ceil((lead + count) / 7) * 7; i++) {
            const d = new Date(month.getFullYear(), month.getMonth(), 1 - lead + i);
            cells.push({
                day: d.getDate(),
                inMonth: d.getMonth() === month.getMonth(),
                today: d.toDateString() === today.toDateString(),
                weekend: i % 7 >= 5
            });
        }
        return cells;
    }

    readonly property int preferredWidth: 320   // the island grows at least this wide
    spacing: 10

    component Arrow: Rectangle {
        property string icon
        signal clicked

        width: 32
        height: 32
        radius: 16
        color: arrowMouse.containsMouse ? Theme.surfaceHigh : "transparent"

        StyledText {
            anchors.centerIn: parent
            text: parent.icon
            font.family: Theme.iconFont
            font.pixelSize: 18
        }

        MouseArea {
            id: arrowMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    Item {
        width: parent.width
        height: 32

        Arrow {
            icon: Icons.chevronLeft
            onClicked: root.offset--
        }

        StyledText {
            anchors.centerIn: parent
            text: {
                const name = Time.locale.standaloneMonthName(root.month.getMonth(), Locale.LongFormat);
                return name.charAt(0).toUpperCase() + name.slice(1) + " " + root.month.getFullYear();
            }
            font.pixelSize: 15
            font.weight: Font.DemiBold

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.offset = 0
            }
        }

        Arrow {
            anchors.right: parent.right
            icon: Icons.chevronRight
            onClicked: root.offset++
        }
    }

    Grid {
        width: parent.width
        columns: 7
        rowSpacing: 2

        Repeater {
            model: 7

            delegate: StyledText {
                required property int index

                width: parent.width / 7
                height: 20
                horizontalAlignment: Text.AlignHCenter
                text: Time.locale.dayName((index + 1) % 7, Locale.ShortFormat)
                font.pixelSize: 11
                color: index >= 5 ? Theme.tertiary : Theme.textVariant
            }
        }

        Repeater {
            model: root.days

            delegate: Item {
                id: cell

                required property var modelData

                width: parent.width / 7
                height: 32

                Rectangle {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    radius: 16
                    color: Theme.primary
                    visible: cell.modelData.today
                }

                StyledText {
                    anchors.centerIn: parent
                    text: cell.modelData.day
                    font.weight: cell.modelData.today ? Font.DemiBold : Font.Normal
                    color: cell.modelData.today ? Theme.textOnPrimary : !cell.modelData.inMonth ? Theme.outline : cell.modelData.weekend ? Theme.tertiary : Theme.text
                }
            }
        }
    }
}
