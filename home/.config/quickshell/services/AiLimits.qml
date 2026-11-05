pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// One snapshot for all screens. Source timestamps survive successful SSH polls.
Singleton {
    id: root

    property var accounts: []
    property bool loaded: false
    property string error: ""
    property string _snapshot: ""
    property int fetchInSeconds: 0
    readonly property bool fetching: request.running
    readonly property real now: clock.date.getTime() / 1000
    readonly property var providers: ["Codex", "Claude"].map(name => ({
        name: name, accounts: accounts.filter(account => account.provider === name)
    }))

    function blockedUntil(account) {
        let until = Math.max(account.rate_limit_reset_at ?? 0, account.overload_until ?? 0,
            account.temp_unschedulable_until ?? 0);
        if (!stale(account.updated_at)) {
            for (const window of account.windows) {
                if (window.used_percent === 100 && window.reset_at !== null)
                    until = Math.max(until, window.reset_at);
            }
        }
        return until > now ? until : null;
    }

    function state(account) {
        if (account.status === "error")
            return "Error";
        if (account.status !== "active")
            return "Disabled";
        if (!account.schedulable)
            return "Paused";
        const until = blockedUntil(account);
        if (until === null)
            return "Active";
        if (until === account.overload_until)
            return "Overloaded";
        if (until === account.temp_unschedulable_until)
            return "Paused";
        return "Limited";
    }

    function stale(updatedAt) {
        return updatedAt === null || now - updatedAt >= 300 || updatedAt > now + 60;
    }

    function age(updatedAt) {
        if (updatedAt === null)
            return "N/A";
        const seconds = Math.max(0, Math.floor(now - updatedAt));
        const minutes = Math.floor(seconds / 60);
        if (seconds < 60)
            return seconds + "s ago";
        if (minutes < 60)
            return minutes + "m ago";
        if (minutes < 1440)
            return Math.floor(minutes / 60) + "h ago";
        return Math.floor(minutes / 1440) + "d ago";
    }

    function reset(resetAt) {
        if (resetAt === null)
            return "N/A";
        if (resetAt <= now)
            return "Awaiting update";
        const minutes = Math.ceil((resetAt - now) / 60);
        if (minutes < 60)
            return minutes + "m";
        if (minutes < 1440)
            return Math.floor(minutes / 60) + "h " + minutes % 60 + "m";
        return Math.floor(minutes / 1440) + "d " + Math.floor(minutes % 1440 / 60) + "h";
    }

    function tokens(value) {
        if (value === null)
            return "N/A";
        if (value < 1000)
            return String(value);
        if (value < 1000000)
            return Number((value / 1000).toFixed(1)) + "k";
        return Number((value / 1000000).toFixed(1)) + "M";
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Process {
        id: request

        command: [Quickshell.shellDir + "/scripts/ai-limits"]
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: errors }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = errors.text.trim() || "Failed to fetch quotas";
                return;
            }
            try {
                const snapshot = JSON.parse(output.text);
                if (!Array.isArray(snapshot.accounts))
                    throw new Error("Missing accounts");
                if (output.text !== root._snapshot) {
                    root.accounts = snapshot.accounts;
                    root._snapshot = output.text;
                }
                root.loaded = true;
                root.error = "";
            } catch (e) {
                root.error = "Invalid quota data";
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.fetchInSeconds = Math.ceil(interval / 1000);
            if (!request.running)
                request.running = true;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.fetchInSeconds = Math.max(0, root.fetchInSeconds - 1)
    }
}
