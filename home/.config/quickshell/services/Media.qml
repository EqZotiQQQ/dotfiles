pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// MPRIS players (Spotify, browsers…). The one shown on the bar: picked in the media popout, or else the
// last one that started playing
Singleton {
    id: root

    // playerctld only mirrors the other players
    readonly property var players: Mpris.players.values.filter(p => !p.dbusName.endsWith(".playerctld"))
    property MprisPlayer chosen: null
    readonly property MprisPlayer player: players.includes(chosen) ? chosen : players.find(p => p.isPlaying) ?? players[0] ?? null
    // live streams report a length of INT64_MAX µs
    readonly property bool hasLength: (player?.lengthSupported ?? false) && player.length > 0 && player.length < 1e7

    // seconds -> m:ss or h:mm:ss
    function fmt(seconds) {
        const s = Math.floor(seconds);
        const ms = Math.floor(s / 60) % 60 + ":" + String(s % 60).padStart(2, "0");
        return s >= 3600 ? Math.floor(s / 3600) + ":" + ms.padStart(5, "0") : ms;
    }

    Instantiator {
        model: Mpris.players

        delegate: Connections {
            required property MprisPlayer modelData

            target: modelData

            function onIsPlayingChanged() {
                if (modelData.isPlaying)
                    root.chosen = modelData;
            }
        }
    }
}
