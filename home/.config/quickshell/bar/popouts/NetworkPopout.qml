import QtQuick
import qs.common
import qs.services

// Wired devices; Wi-Fi on/off and the networks in range: click connects / disconnects,
// a new secured network asks for its password right here
Column {
    id: root

    readonly property int preferredWidth: 400   // the island grows at least this wide
    property var asking: null     // the network the password field is for
    readonly property bool wantsKeyboard: asking !== null   // the bar takes the keyboard meanwhile (StatusIsland)
    property var pending: null    // the network last asked to connect: its failure is shown here
    property string error: ""

    function join(net) {
        error = "";
        pending = net;
        if (!net.known && Network.needsPsk(net))
            ask(net);
        else
            net.connect();
    }

    function ask(net) {
        asking = net;
        password.text = "";
        password.forceActiveFocus();
    }

    function submit() {
        if (password.text === "")
            return;
        error = "";
        pending = asking;
        asking.connectWithPsk(password.text);
        asking = null;
    }

    function cancel() {
        asking = null;
        error = "";
    }

    spacing: 12

    Component.onCompleted: Network.watchers++
    Component.onDestruction: Network.watchers--

    // a wrong (or stale saved) password fails the connection: ask for it again
    Connections {
        target: root.pending

        function onConnectionFailed(reason) {
            if (Network.needsPsk(root.pending)) {
                root.error = "Не удалось подключиться — проверьте пароль";
                root.ask(root.pending);
            } else {
                root.error = "Не удалось подключиться";
            }
        }

        function onConnectedChanged() {
            if (root.pending.connected)
                root.error = "";
        }
    }

    Header {
        width: parent.width
        title: "Сеть"
    }

    Repeater {
        model: Network.wired

        delegate: Item {
            id: wired

            required property var modelData
            readonly property int speed: modelData.linkSpeed   // Mbit/s

            width: parent.width
            height: 24

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Icons.ethernet
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: wired.modelData.name
                }
            }

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: !wired.modelData.hasLink ? "нет кабеля" : !wired.modelData.connected ? "отключено" : wired.speed >= 1000 ? wired.speed / 1000 + " Гбит/с" : wired.speed + " Мбит/с"
                color: wired.modelData.connected ? Theme.text : Theme.textVariant
            }
        }
    }

    Column {
        width: parent.width
        spacing: 8
        visible: Network.wifi !== null

        // the whole row toggles Wi-Fi
        Item {
            width: parent.width
            height: 32

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Network.wifiEnabled ? Icons.wifi : Icons.wifiOff
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi"
                    font.weight: Font.DemiBold
                }
            }

            StyledText {
                anchors.right: toggle.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: !Network.wifiHardwareEnabled
                text: "выключен аппаратно"
                color: Theme.textVariant
            }

            Rectangle {
                id: toggle

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 24
                radius: 12
                color: Network.wifiEnabled ? Theme.primary : Theme.surfaceHigh
                border.width: Network.wifiEnabled ? 0 : 1
                border.color: Theme.outline
                opacity: Network.wifiHardwareEnabled ? 1 : 0.4

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Network.wifiEnabled ? parent.width - width - 4 : 4
                    width: 16
                    height: 16
                    radius: 8
                    color: Network.wifiEnabled ? Theme.textOnPrimary : Theme.outline

                    Behavior on x {
                        NumberAnimation {
                            duration: 160
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: Network.wifiHardwareEnabled
                cursorShape: Qt.PointingHandCursor
                onClicked: Network.setWifiEnabled(!Network.wifiEnabled)
            }
        }

        StyledText {
            visible: Network.wifiEnabled && list.count === 0
            text: "Поиск сетей…"
            color: Theme.textVariant
        }

        ListView {
            id: list

            width: parent.width
            height: Math.min(contentHeight, 320)
            visible: Network.wifiEnabled && count > 0
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            model: Network.networks

            delegate: Rectangle {
                id: net

                required property var modelData
                readonly property color fg: modelData.connected ? Theme.textOnPrimaryContainer : Theme.text

                width: ListView.view.width
                height: 38
                radius: 14
                color: modelData.connected ? Theme.primaryContainer : netMouse.containsMouse ? Theme.surfaceHigh : "transparent"

                StyledText {
                    id: strength

                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    text: (Network.isOpen(net.modelData) ? Icons.wifiStrength : Icons.wifiStrengthLock)[Math.round(net.modelData.signalStrength * 4)]
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                    color: net.fg
                }

                StyledText {
                    anchors.left: strength.right
                    anchors.leftMargin: 10
                    anchors.right: status.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: net.modelData.name
                    elide: Text.ElideRight
                    color: net.fg
                }

                StyledText {
                    id: status

                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: net.modelData.connected ? "подключено" : net.modelData.stateChanging ? "подключение…" : net.modelData.known ? "сохранена" : ""
                    font.pixelSize: 12
                    color: net.modelData.connected ? Theme.textOnPrimaryContainer : Theme.textVariant
                }

                MouseArea {
                    id: netMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: net.modelData.connected ? net.modelData.disconnect() : root.join(net.modelData)
                }
            }
        }

        StyledText {
            width: parent.width
            visible: root.error !== ""
            text: root.error
            wrapMode: Text.Wrap
            color: Theme.error
        }

        // Enter connects, Escape cancels
        Rectangle {
            width: parent.width
            height: 44
            radius: Theme.chipRadius
            color: Theme.surfaceHigh
            visible: root.asking !== null

            TextInput {
                id: password

                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                echoMode: TextInput.Password
                color: Theme.text
                selectionColor: Theme.primaryContainer
                selectedTextColor: Theme.textOnPrimaryContainer
                font.family: Theme.uiFont
                font.pixelSize: Theme.fontSize + 2
                Keys.onReturnPressed: root.submit()
                Keys.onEnterPressed: root.submit()
                Keys.onEscapePressed: root.cancel()

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    text: "Пароль для «" + (root.asking?.name ?? "") + "»"
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontSize + 2
                    color: Theme.textVariant
                    visible: password.text === ""
                }
            }
        }
    }
}
