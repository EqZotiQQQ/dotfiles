pragma Singleton

import QtQuick
import Quickshell

// Current time (to the minute) and the LC_TIME locale for day/month names
Singleton {
    readonly property date date: clock.date
    readonly property var locale: Qt.locale((Quickshell.env("LC_TIME") || Quickshell.env("LANG") || "C").split(".")[0])

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
