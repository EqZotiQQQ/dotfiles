import QtQuick

// Number animation on the theme's curve (slight overshoot): use in Behaviors
NumberAnimation {
    duration: Theme.duration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Theme.bezier
}
