import QtQuick

Item {
    id: root

    required property string monitorName
    required property string mode
    required property int delayMs
    required property real pressureThreshold
    required property int fadeMs

    property bool atEdge: false
    property real pressure: 0
    property real target: 0
    readonly property real progress: reveal.value

    function reset() {
        dwell.stop();
        atEdge = false;
        pressure = 0;
        target = 0;
    }

    function sample(monitor, upward) {
        if (!enabled || monitor !== monitorName) {
            reset();
            return;
        }
        if (!atEdge) {
            atEdge = true;
            if (mode === "delay")
                dwell.start();
        }
        if (mode === "pressure") {
            pressure = Math.max(0, Math.min(pressureThreshold, pressure + upward));
            target = pressure / pressureThreshold;
        }
    }

    onModeChanged: reset()
    onDelayMsChanged: reset()
    onPressureThresholdChanged: reset()
    onEnabledChanged: reset()
    onMonitorNameChanged: reset()

    QtObject {
        id: reveal
        property real value: root.target
        Behavior on value {
            SmoothedAnimation {
                duration: root.fadeMs
                // Keep duration in control for the 0..1 opacity range.
                velocity: -1
                reversingMode: SmoothedAnimation.Immediate
            }
        }
    }

    Timer {
        id: dwell
        interval: root.delayMs
        onTriggered: root.target = 1
    }
}
