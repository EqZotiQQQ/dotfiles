import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // qylock loads this file dynamically, outside the bar's singleton module.
    readonly property var theme: JSON.parse(themeFile.text())

    FileView {
        id: themeFile
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/theme/theme.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    property date now: new Date()
    property bool busy: false
    property bool failed: false

    function login() {
        if (password.text === "" || busy)
            return;
        busy = true;
        failed = false;
        sddm.login(userModel.lastUser, password.text, sessionModel.lastIndex);
    }

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers/" + root.theme.wallpaper
        fillMode: Image.PreserveAspectCrop
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // qylock's Loader takes focus after loading the theme.
    Timer {
        interval: 300
        running: true
        onTriggered: password.forceActiveFocus()
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.busy = false;
            root.failed = true;
            password.text = "";
            password.forceActiveFocus();
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(420, root.width - 48)
        height: contents.implicitHeight + 64
        color: root.theme.colors.surface
        border.color: root.theme.colors.outlineVariant
        radius: 8

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
            height: 3
            color: root.theme.colors.primary
        }

        Column {
            id: contents
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 14

            Text {
                width: parent.width
                text: Qt.formatTime(root.now, "HH:mm")
                color: root.theme.colors.onSurface
                font { family: root.theme.fonts.mono; pixelSize: 72; weight: Font.Light }
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: Qt.formatDate(root.now, "dddd, d MMMM")
                color: root.theme.colors.onSurfaceVariant
                font { family: root.theme.fonts.ui; pixelSize: 15 }
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 4
                color: root.theme.colors.surfaceHigh
                border.color: root.failed ? root.theme.colors.error : root.theme.colors.tertiary

                TextInput {
                    id: password
                    anchors { fill: parent; margins: 12 }
                    color: root.theme.colors.onSurface
                    selectionColor: root.theme.colors.primary
                    selectedTextColor: root.theme.colors.onPrimary
                    font { family: root.theme.fonts.mono; pixelSize: 18 }
                    echoMode: TextInput.Password
                    enabled: !root.busy
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter
                    onAccepted: root.login()
                }

                Text {
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    visible: password.text === ""
                    text: "Password"
                    color: root.theme.colors.onSurfaceVariant
                    font { family: root.theme.fonts.ui; pixelSize: 15 }
                }
            }

            Text {
                width: parent.width
                text: root.failed ? "Incorrect password. Try again." : root.busy ? "Unlocking…" : "Press Enter to unlock"
                color: root.failed ? root.theme.colors.error : root.theme.colors.onSurfaceVariant
                font { family: root.theme.fonts.ui; pixelSize: 13 }
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
