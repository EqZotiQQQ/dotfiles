import QtQuick
import Quickshell.Bluetooth
import qs.common
import qs.services

// Wireless mice and keyboards: battery with the last day's graph and how long it lasts at the current drain,
// polling rate (set, and seen on input while the mouse moves), DPI, profile, firmware. Below them the paired
// Bluetooth devices the script doesn't report: click connects / disconnects
Column {
    readonly property int preferredWidth: 380   // the island grows at least this wide
    spacing: 16

    Component.onCompleted: Wireless.watchers++
    Component.onDestruction: Wireless.watchers--

    Header {
        width: parent.width
        title: "Устройства"
    }

    StyledText {
        visible: Wireless.devices.length === 0 && Wireless.bluetooth.length === 0
        text: "Нет беспроводных устройств"
        color: Theme.textVariant
    }

    Repeater {
        model: Wireless.devices

        delegate: Column {
            id: dev

            required property var modelData
            readonly property var d: modelData
            readonly property int seen: Wireless.measured[d.id] ?? 0
            // label, value, label, value… for the grid
            readonly property var details: [
                ["Опрос", d.rate || seen ? [d.rate ? d.rate + " Гц" : "", seen ? "факт " + seen + " Гц" : ""].filter(s => s).join(" · ") : null],
                ["DPI", d.dpi],
                ["Профиль", d.profile != null ? d.profile + " из " + d.profiles : null],
                ["Канал", d.host != null ? d.host + " из " + d.hosts : null],
                ["Хватит на", d.hoursLeft != null ? Wireless.duration(d.hoursLeft) : null],
                ["Расход", d.drain != null ? d.drain + " %/ч" : null],
                ["Сон через", d.idle ? Math.round(d.idle / 60) + " мин" : null],
                ["Прошивка", d.firmware]
            ].filter(p => p[1] != null).reduce((all, p) => all.concat(p), [])

            width: parent.width
            spacing: 8
            opacity: d.online ? 1 : 0.6

            Item {
                width: parent.width
                height: 24

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Wireless.icon(dev.d.kind)
                        font.family: Theme.iconFont
                        font.pixelSize: 16
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: dev.d.name
                        font.weight: Font.DemiBold
                    }
                }

                StyledText {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: [dev.d.link, !dev.d.online ? "не на связи, " + Wireless.ago(dev.d.seen) : dev.d.full ? "заряжена" : dev.d.charging ? "заряжается" : ""].filter(s => s).join(" · ")
                    font.pixelSize: 12
                    color: Theme.textVariant
                }
            }

            Meter {
                width: parent.width
                visible: dev.d.battery != null
                label: "Заряд"
                value: (dev.d.battery ?? 0) / 100
                detail: dev.d.battery + "%"
                barColor: dev.d.charging ? Theme.tertiary : dev.d.battery <= 15 ? Theme.error : Theme.primary
            }

            // battery over the last day, held at the last value up to now while on air; once it spans an hour
            Canvas {
                width: parent.width
                height: 32
                visible: dev.d.history.length > 1 && dev.d.history[dev.d.history.length - 1][0] - dev.d.history[0][0] >= 3600
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const now = Date.now() / 1000;
                    const h = dev.d.history;
                    const x = t => width * (1 - (now - t) / 86400);
                    const y = p => height - 1 - (height - 2) * p / 100;
                    const line = () => {
                        ctx.beginPath();
                        ctx.moveTo(x(h[0][0]), y(h[0][1]));
                        for (const s of h)
                            ctx.lineTo(x(s[0]), y(s[1]));
                        if (dev.d.online)
                            ctx.lineTo(width, y(h[h.length - 1][1]));
                    };
                    line();
                    ctx.lineTo(dev.d.online ? width : x(h[h.length - 1][0]), height);
                    ctx.lineTo(x(h[0][0]), height);
                    ctx.fillStyle = Theme.alpha(Theme.primary, 0.15);
                    ctx.fill();
                    line();
                    ctx.strokeStyle = Theme.primary;
                    ctx.lineWidth = 1.5;
                    ctx.stroke();
                }

                StyledText {
                    text: "сутки"
                    font.pixelSize: 11
                    color: Theme.textVariant
                }
            }

            Grid {
                columns: 2
                columnSpacing: 16
                rowSpacing: 4

                Repeater {
                    model: dev.details

                    delegate: StyledText {
                        required property var modelData
                        required property int index

                        text: String(modelData)
                        font.pixelSize: 12
                        font.family: index % 2 ? Theme.monoFont : Theme.uiFont
                        color: index % 2 ? Theme.text : Theme.textVariant
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: Wireless.bluetooth.length > 0

        Item {
            width: parent.width
            height: 28

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Bluetooth"
                font.weight: Font.DemiBold
            }

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: !(Bluetooth.defaultAdapter?.enabled ?? false)
                text: "выключен"
                font.pixelSize: 12
                color: Theme.textVariant
            }
        }

        Repeater {
            model: Wireless.bluetooth

            delegate: Rectangle {
                id: bt

                required property BluetoothDevice modelData
                readonly property var d: modelData
                readonly property bool busy: d.state === BluetoothDeviceState.Connecting || d.state === BluetoothDeviceState.Disconnecting
                readonly property color fg: d.connected ? Theme.textOnPrimaryContainer : Theme.text

                width: parent.width
                height: 38
                radius: 14
                color: d.connected ? Theme.primaryContainer : btMouse.containsMouse ? Theme.surfaceHigh : "transparent"

                StyledText {
                    id: btIcon

                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    text: bt.d.icon.startsWith("input-mouse") ? Icons.mouse : bt.d.icon.startsWith("input-keyboard") ? Icons.keyboard : bt.d.icon.startsWith("audio") ? Icons.headphones : Icons.bluetooth
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                    color: bt.fg
                }

                StyledText {
                    anchors.left: btIcon.right
                    anchors.leftMargin: 10
                    anchors.right: btState.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: bt.d.name
                    elide: Text.ElideRight
                    color: bt.fg
                }

                StyledText {
                    id: btState

                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: bt.busy ? "…" : !bt.d.connected ? "не подключено" : bt.d.batteryAvailable ? Math.round(bt.d.battery * 100) + "%" : "подключено"
                    font.pixelSize: 12
                    color: bt.d.connected ? Theme.textOnPrimaryContainer : Theme.textVariant
                }

                MouseArea {
                    id: btMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !bt.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bt.d.connected ? bt.d.disconnect() : bt.d.connect()
                }
            }
        }
    }
}
