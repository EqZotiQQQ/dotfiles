import QtQuick

// pixel-city: pixel-art night city in the rain, with a big pixel clock.
// A lockscreen theme for qylock's Quickshell lockscreen (`lock`), written against the SDDM theme API
// (sddm.login(), userModel, sessionModel, config) so it also works as an SDDM greeter theme.
// Options: theme.conf
Item {
    id: root

    // the scene is ~112 pixel-art pixels tall at any resolution
    readonly property int px: Math.max(4, Math.round(height / 112))
    readonly property bool rain: (typeof config !== "undefined" ? config.rain : "true") !== "false"
    readonly property var locale: Qt.locale(typeof config !== "undefined" && config.locale ? config.locale : "")
    property date now: new Date()
    property bool busy: false

    readonly property color ink: "#F4E9C9"
    readonly property color ice: "#BFC8FF"
    readonly property color pink: "#FF8FB1"
    readonly property color night: "#0E0E25"

    function login() {
        if (pwd.text === "" || busy)
            return;
        busy = true;
        error.visible = false;
        sddm.login(userModel.lastUser, pwd.text, typeof sessionModel !== "undefined" ? sessionModel.lastIndex : 0);
    }

    // deterministic pseudo-random numbers, so the city looks the same on every lock
    function rng(seed) {
        let s = seed >>> 0;
        return () => {
            s = (s + 0x6D2B79F5) >>> 0;
            let t = s;
            t = Math.imul(t ^ (t >>> 15), t | 1);
            t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
            return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
        };
    }

    FontLoader {
        id: digits

        source: "font/PixelifySans.ttf"
    }

    FontLoader {
        id: pixel

        source: "font/PressStart2P-Regular.ttf"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // Quickshell's Loader doesn't pass focus on, so take it explicitly
    Timer {
        interval: 300
        running: true
        onTriggered: pwd.forceActiveFocus()
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null

        function onLoginFailed() {
            root.busy = false;
            pwd.text = "";
            error.visible = true;
            shake.restart();
            pwd.forceActiveFocus();
        }
    }

    // Sky, moon, buildings, lit windows: painted once per size
    Canvas {
        id: scene

        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            const u = root.px;
            const W = width, H = height;
            const rand = root.rng(7);
            const box = (x, y, w, h, color) => {
                ctx.fillStyle = color;
                ctx.fillRect(x, y, w, h);
            };
            const snap = v => Math.round(v / u) * u;

            // sky: flat bands, dithered into each other
            const bands = ["#0A0A1C", "#0E0E25", "#13122F", "#19173A", "#211D46", "#2B2453", "#372B5E"];
            const tops = [0, 0.151, 0.284, 0.4, 0.507, 0.604, 0.693].map(f => snap(f * H));
            bands.forEach((c, i) => box(0, tops[i], W, H - tops[i], c));
            for (let i = 1; i < bands.length; i++) {
                ctx.fillStyle = bands[i];
                for (let x = 0; x < W; x += 4 * u)
                    ctx.fillRect(x, tops[i] - 2 * u, u, u);
                for (let x = u; x < W; x += 2 * u)
                    ctx.fillRect(x, tops[i] - u, u, u);
            }

            // stars
            for (let i = 0; i < 40; i++)
                box(snap(rand() * W), snap(rand() * H * 0.55), rand() > 0.8 ? u : u / 2, rand() > 0.8 ? u : u / 2, rand() > 0.5 ? root.ink : root.ice);

            // moon with a halo and craters
            const mx = snap(W * 0.81), my = snap(H * 0.187);
            const disc = (r, color) => {
                for (let j = -r; j < r; j++) {
                    const half = Math.round(Math.sqrt(r * r - (j + 0.5) * (j + 0.5)));
                    box(mx - half * u, my + j * u, half * 2 * u, u, color);
                }
            };
            disc(11, "rgba(241, 230, 200, 0.06)");
            disc(7, "#F1E6C8");
            box(mx - 3 * u, my - 3 * u, 2 * u, 2 * u, "#D8CBA6");
            box(mx + 2 * u, my + u, u, u, "#D8CBA6");
            box(mx - u, my + 3 * u, u, u, "#D8CBA6");

            const ground = H - 3 * u;

            // far buildings: tall, few dim windows, some antennas
            for (let x = -2 * u; x < W;) {
                const w = (8 + Math.floor(rand() * 13)) * u;
                const h = (30 + Math.floor(rand() * 29)) * u;
                box(x, ground - h, w, h, "#1B1838");
                if (rand() > 0.72)
                    box(x + Math.floor(w / 2 / u) * u, ground - h - 4 * u, u / 2, 4 * u, "#1B1838");
                for (let wy = ground - h + 3 * u; wy < ground - 2 * u; wy += 3 * u)
                    for (let wx = x + 2 * u; wx < x + w - 2 * u; wx += 3 * u)
                        if (rand() < 0.08)
                            box(wx, wy, u, u, "rgba(255, 196, 107, 0.45)");
                x += w + (rand() > 0.6 ? u : 0);
            }

            // near buildings: lower, darker, lots of lit windows
            const lights = ["#FFC46B", "#FFC46B", "#FFC46B", "#FF8FB1", "#8FE3FF"];
            for (let x = -3 * u; x < W;) {
                const w = (12 + Math.floor(rand() * 14)) * u;
                const h = (15 + Math.floor(rand() * 28)) * u;
                box(x, ground - h, w, h, "#110F24");
                box(x, ground - h, w, u / 2, "#1D1A38");
                for (let wy = ground - h + 2 * u; wy < ground - 2 * u; wy += 4 * u)
                    for (let wx = x + 2 * u; wx < x + w - 2 * u; wx += 3 * u)
                        if (rand() < 0.3)
                            box(wx, wy, u, 2 * u, lights[Math.floor(rand() * lights.length)]);
                x += w;
            }

            box(0, ground, W, H - ground, "#0A0918");
        }
    }

    // a few stars twinkle
    Repeater {
        model: 12

        delegate: Rectangle {
            required property int index
            readonly property var rand: root.rng(100 + index)

            x: Math.round(rand() * root.width / root.px) * root.px
            y: Math.round(rand() * root.height * 0.5 / root.px) * root.px
            width: root.px / 2
            height: root.px / 2
            color: root.ink

            SequentialAnimation on opacity {
                loops: Animation.Infinite

                PauseAnimation {
                    duration: 800 + 3000 * Math.random()
                }
                PropertyAction {
                    value: 0.2
                }
                PauseAnimation {
                    duration: 600 + 1200 * Math.random()
                }
                PropertyAction {
                    value: 1
                }
            }
        }
    }

    // rain: each drop falls on a loop, started at a random phase
    Repeater {
        model: root.rain ? 90 : 0

        delegate: Rectangle {
            id: drop

            required property int index
            readonly property var rand: root.rng(1000 + index)
            readonly property real phase: rand()
            property real t: 0

            x: Math.round(rand() * root.width / (root.px / 2)) * (root.px / 2)
            y: ((t + phase) % 1) * (root.height + height) - height
            width: Math.max(2, root.px / 4)
            height: (2 + Math.floor(rand() * 2)) * root.px
            color: Qt.rgba(0.67, 0.73, 1, 0.35)

            NumberAnimation on t {
                from: 0
                to: 1
                duration: 700 + 600 * drop.rand()
                loops: Animation.Infinite
            }
        }
    }

    // Stepped (pixel-cornered) rectangle
    component Stepped: Item {
        property color color
        readonly property int s: root.px

        Rectangle {
            x: parent.s
            width: parent.width - 2 * parent.s
            height: parent.height
            color: parent.color
        }
        Rectangle {
            y: parent.s
            width: parent.width
            height: parent.height - 2 * parent.s
            color: parent.color
        }
        Rectangle {
            x: parent.s / 2
            y: parent.s / 2
            width: parent.width - parent.s
            height: parent.height - parent.s
            color: parent.color
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.19
        spacing: 2 * root.px

        // clock with a hard pixel shadow
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: clock.implicitWidth
            height: clock.implicitHeight

            Text {
                x: root.px
                y: root.px
                text: clock.text
                font: clock.font
                color: "#2B2453"
            }

            Text {
                id: clock

                text: Qt.formatTime(root.now, "HH:mm")
                font.family: digits.name
                font.weight: Font.DemiBold
                font.pixelSize: 23 * root.px
                color: root.ink
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.now.toLocaleDateString(root.locale, "dddd, d MMMM").toUpperCase()
            font.family: pixel.name
            font.pixelSize: 2 * root.px
            font.letterSpacing: root.px / 4
            color: root.ice
        }

        Item {
            width: 1
            height: 3 * root.px
        }

        Item {
            id: field

            anchors.horizontalCenter: parent.horizontalCenter
            width: 48 * root.px
            height: 7 * root.px

            Stepped {
                anchors.fill: parent
                color: error.visible ? root.pink : root.ice
            }

            Stepped {
                anchors.fill: parent
                anchors.margins: root.px / 2
                color: root.night
            }

            // pixel padlock
            Item {
                x: 2 * root.px
                anchors.verticalCenter: parent.verticalCenter
                width: 3 * root.px
                height: 3 * root.px

                readonly property real p: root.px * 3 / 8

                Rectangle { x: 2 * parent.p; width: 4 * parent.p; height: parent.p; color: root.ice }
                Rectangle { x: parent.p; y: parent.p; width: parent.p; height: 3 * parent.p; color: root.ice }
                Rectangle { x: 6 * parent.p; y: parent.p; width: parent.p; height: 3 * parent.p; color: root.ice }
                Rectangle { y: 3 * parent.p; width: 8 * parent.p; height: 5 * parent.p; color: root.ice }
                Rectangle { x: 3 * parent.p; y: 5 * parent.p; width: 2 * parent.p; height: 2 * parent.p; color: root.night }
            }

            TextInput {
                id: pwd

                anchors.fill: parent
                anchors.leftMargin: 7 * root.px
                anchors.rightMargin: 2 * root.px
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "*"
                focus: true
                clip: true
                enabled: !root.busy
                font.family: pixel.name
                font.pixelSize: Math.round(1.75 * root.px)
                font.letterSpacing: root.px / 2
                color: root.ink
                selectionColor: root.ice
                cursorDelegate: Rectangle {
                    width: root.px / 2
                    color: "#FFC46B"
                    visible: pwd.activeFocus
                }
                onTextEdited: error.visible = false
                Keys.onReturnPressed: root.login()
                Keys.onEnterPressed: root.login()
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: pwd.x
                visible: pwd.text === ""
                text: root.busy ? "ПРОВЕРКА..." : "ПАРОЛЬ"
                font: pwd.font
                color: "#6E6798"
            }

            SequentialAnimation {
                id: shake

                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -root.px; duration: 60 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: root.px; duration: 60 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -root.px / 2; duration: 60 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 60 }
            }
        }

        Text {
            id: error

            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: "НЕВЕРНЫЙ ПАРОЛЬ"
            font.family: pixel.name
            font.pixelSize: Math.round(1.4 * root.px)
            color: root.pink
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !error.visible
            text: "ENTER — РАЗБЛОКИРОВАТЬ"
            font.family: pixel.name
            font.pixelSize: Math.round(1.4 * root.px)
            color: "#9A92C4"
        }
    }

    // power off
    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4 * root.px
        width: 4 * root.px
        height: 4 * root.px
        opacity: powerMouse.containsMouse ? 1 : 0.7

        readonly property real p: root.px / 2

        Rectangle { x: 3 * parent.p; width: 2 * parent.p; height: 4 * parent.p; color: root.ice }
        Rectangle { x: parent.p; y: 2 * parent.p; width: parent.p; height: parent.p; color: root.ice }
        Rectangle { x: 6 * parent.p; y: 2 * parent.p; width: parent.p; height: parent.p; color: root.ice }
        Rectangle { y: 3 * parent.p; width: parent.p; height: 3 * parent.p; color: root.ice }
        Rectangle { x: 7 * parent.p; y: 3 * parent.p; width: parent.p; height: 3 * parent.p; color: root.ice }
        Rectangle { x: parent.p; y: 6 * parent.p; width: parent.p; height: parent.p; color: root.ice }
        Rectangle { x: 6 * parent.p; y: 6 * parent.p; width: parent.p; height: parent.p; color: root.ice }
        Rectangle { x: 2 * parent.p; y: 7 * parent.p; width: 4 * parent.p; height: parent.p; color: root.ice }

        MouseArea {
            id: powerMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sddm.powerOff()
        }
    }
}
