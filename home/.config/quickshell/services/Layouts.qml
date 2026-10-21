pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Layout chosen per workspace (hypr/layouts.lua): read from the file layouts.lua rewrites on every change
Singleton {
    id: root

    property var json: ({})

    // workspaces nobody switched yet have the default
    function of(workspace) {
        return (json.workspaces ?? {})[workspace] ?? json.default ?? "";
    }

    // next (step 1) or previous (-1) layout of a workspace
    function cycle(step, workspace) {
        Hyprland.dispatch(`function() require("layouts").cycle(${step}, ${workspace}) end`);
    }

    FileView {
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/hypr-layouts.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.json = JSON.parse(text());
            } catch (e) {
                console.warn("hypr-layouts.json:", e);
            }
        }
    }
}
