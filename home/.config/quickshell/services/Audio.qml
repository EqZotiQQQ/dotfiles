pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default PipeWire sink: volume, mute, switching between output devices
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    // output devices, not app streams
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)

    function setVolume(v) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1.5, v));
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setDefault(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // volume/mute of a node are only live while it's tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
