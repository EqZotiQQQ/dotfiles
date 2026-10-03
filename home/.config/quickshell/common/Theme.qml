pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Shared theme: ~/.config/theme/theme.json, re-read live whenever the file changes.
// The same file drives Hyprland (hypr/theme.lua) and the lockscreen (`lock`); keys: ~/.config/theme/README.md
Singleton {
    id: root

    property var json: ({})

    readonly property var colors: json.colors ?? ({})
    readonly property var shape: json.shape ?? ({})
    readonly property var motion: json.motion ?? ({})
    readonly property var fonts: json.fonts ?? ({})

    // Neutral fallbacks only keep the bar readable until theme.json is loaded
    readonly property color primary: colors.primary ?? "#cccccc"
    readonly property color textOnPrimary: colors.onPrimary ?? "#202020"
    readonly property color primaryContainer: colors.primaryContainer ?? "#505050"
    readonly property color textOnPrimaryContainer: colors.onPrimaryContainer ?? "#eeeeee"
    readonly property color secondary: colors.secondary ?? "#bbbbbb"
    readonly property color tertiary: colors.tertiary ?? "#bbbbbb"
    readonly property color error: colors.error ?? "#ff8080"
    readonly property color surface: colors.surface ?? "#202020"
    readonly property color surfaceHigh: colors.surfaceHigh ?? "#383838"
    readonly property color text: colors.onSurface ?? "#eeeeee"
    readonly property color textVariant: colors.onSurfaceVariant ?? "#cccccc"
    readonly property color outline: colors.outline ?? "#999999"
    readonly property color outlineVariant: colors.outlineVariant ?? "#505050"

    // Translucent island background (blurred by Hyprland: layer rule "bar-blur")
    readonly property real panelOpacity: json.opacity?.panel ?? 0.82
    readonly property color panel: alpha(surface, panelOpacity)

    readonly property int barHeight: shape.barHeight ?? 48
    readonly property int barMargin: shape.barMargin ?? 10
    readonly property int islandRadius: shape.islandRadius ?? 24
    readonly property int tileRadius: shape.tileRadius ?? 12
    readonly property int chipRadius: shape.chipRadius ?? 18

    // Theme curve as a QML BezierSpline: control points + end point
    readonly property var curve: motion.curve ?? [0.05, 0.9, 0.1, 1.05]
    readonly property var bezier: [curve[0], curve[1], curve[2], curve[3], 1, 1]
    readonly property int duration: motion.durationMs ?? 460

    readonly property string uiFont: fonts.ui ?? "sans-serif"
    readonly property string monoFont: fonts.mono ?? "monospace"
    readonly property string iconFont: fonts.icons ?? "Symbols Nerd Font"
    readonly property int fontSize: fonts.size ?? 13

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/theme/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.json = JSON.parse(text());
            } catch (e) {
                console.warn("theme.json:", e);
            }
        }
    }
}
