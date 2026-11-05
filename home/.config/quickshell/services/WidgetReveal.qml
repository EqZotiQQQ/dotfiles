pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.common

Singleton {
    id: root

    readonly property var config: Theme.json.widgetReveal
    readonly property var backdrop: config?.backdrop
    readonly property bool valid: config !== undefined && config !== null
        && ["delay", "pressure"].includes(config.mode)
        && Number.isInteger(config.delayMs) && config.delayMs >= 0
        && Number.isFinite(config.pressureThreshold) && config.pressureThreshold > 0
        && Number.isInteger(config.fadeMs) && config.fadeMs >= 0
        && Number.isFinite(config.gap) && config.gap >= 0 && config.gap <= 4096
        && backdrop !== undefined && backdrop !== null
        && typeof backdrop.color === "string" && /^#[0-9a-fA-F]{6}$/.test(backdrop.color)
        && Number.isFinite(backdrop.opacity) && backdrop.opacity >= 0 && backdrop.opacity <= 1
        && Number.isFinite(backdrop.padding) && backdrop.padding >= 0 && backdrop.padding <= 4096
        && Number.isFinite(backdrop.radius) && backdrop.radius >= 0 && backdrop.radius <= 4096
        && typeof backdrop.blur === "boolean"
        && Number.isFinite(backdrop.blurOpacity) && backdrop.blurOpacity >= 0 && backdrop.blurOpacity <= 1
    property bool ready: false
    property bool loaded: false
    property string error: ""
    property var proctreeBounds: ({})

    signal sample(string monitor, real upward)

    function revealWidgets(monitor, progress) {
        if (!loaded || !valid)
            return;
        const background = Qt.color(backdrop.color);
        Hyprland.dispatch("function() hl.plugin.widget_edge.reveal(" + JSON.stringify(monitor) + ", "
            + [progress, background.r, background.g, background.b, backdrop.opacity,
                backdrop.padding, backdrop.radius, backdrop.blur, backdrop.blurOpacity, config.gap].join(", ") + ") end");
    }

    function updateBounds(data) {
        const parts = data.split(",");
        const name = parts[0];
        const next = Object.assign({}, proctreeBounds);
        if (parts.length === 1) {
            if (next[name] === undefined)
                return;
            delete next[name];
        } else {
            const values = parts.slice(1).map(Number);
            if (values.length !== 4 || !values.every(Number.isFinite) || values[2] <= 0 || values[3] <= 0) {
                fail("Некорректные границы proctree");
                return;
            }
            const bounds = {x: values[0], y: values[1], width: values[2], height: values[3]};
            if (JSON.stringify(next[name]) === JSON.stringify(bounds))
                return;
            next[name] = bounds;
        }
        proctreeBounds = next;
    }

    function fail(message) {
        heartbeat.stop();
        ready = false;
        loaded = false;
        proctreeBounds = {};
        sample("", 0);
        if (error === message)
            return;
        error = message;
        console.error("widget-edge:", message);
        Quickshell.execDetached(["notify-send", "Виджеты у края экрана", message]);
    }

    function configure() {
        if (Object.keys(Theme.json).length === 0)
            return;
        if (!valid)
            fail("Некорректные настройки widgetReveal в theme.json");
        else if (!ready && !detector.running) {
            error = "";
            detector.running = true;
        }
    }

    Component.onCompleted: Qt.callLater(configure)

    Connections {
        target: Theme
        // Derived bindings must settle before validating the new JSON.
        function onJsonChanged() { Qt.callLater(root.configure); }
    }

    Process {
        id: detector
        command: [Quickshell.shellDir + "/scripts/widget-edge"]
        stderr: StdioCollector { id: errors }
        onExited: (code, status) => {
            if (code !== 0 || status !== 0)
                root.fail(errors.text.trim() || "Не удалось загрузить детектор края; см. qs log");
            else if (root.valid) {
                root.loaded = true;
                heartbeat.restart();
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!root.valid || !root.loaded)
                return;
            if (event.name === "widgetbounds") {
                root.updateBounds(event.data);
                return;
            }
            if (event.name !== "widgetedge")
                return;
            const parts = event.data.split(",");
            const upward = Number(parts[1]);
            if (parts.length !== 2 || !Number.isFinite(upward)) {
                root.fail("Некорректное событие widgetedge");
                return;
            }
            root.error = "";
            root.ready = true;
            heartbeat.restart();
            root.sample(parts[0], upward);
        }
    }

    Timer {
        id: heartbeat
        interval: 1500
        onTriggered: root.fail("Детектор края не отвечает; перезапустите Quickshell и проверьте qs log")
    }
}
