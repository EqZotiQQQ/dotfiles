import QtQuick
import qs.services

EdgeRevealState {
    id: root

    enabled: WidgetReveal.valid && WidgetReveal.ready
    mode: WidgetReveal.valid ? WidgetReveal.config.mode : ""
    delayMs: WidgetReveal.valid ? WidgetReveal.config.delayMs : 0
    pressureThreshold: WidgetReveal.valid ? WidgetReveal.config.pressureThreshold : 1
    fadeMs: WidgetReveal.valid ? WidgetReveal.config.fadeMs : 0

    onProgressChanged: WidgetReveal.revealWidgets(monitorName, progress)
    Component.onDestruction: WidgetReveal.revealWidgets(monitorName, 0)

    Connections {
        target: WidgetReveal
        function onSample(monitor, upward) { root.sample(monitor, upward); }
    }

    // The plugin expires a reveal if Quickshell exits without sending the final zero.
    Timer {
        interval: 500
        running: root.progress > 0
        repeat: true
        onTriggered: WidgetReveal.revealWidgets(root.monitorName, root.progress)
    }
}
