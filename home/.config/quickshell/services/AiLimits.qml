pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

// One snapshot for all screens. Source timestamps survive successful SSH polls.
Singleton {
    id: root

    property var accounts: []
    property bool loaded: false
    property string error: ""
    property string _snapshot: ""
    readonly property real now: Time.date.getTime() / 1000
    readonly property int enabledCount: accounts.filter(a => enabled(a)).length
    readonly property int limitedCount: accounts.filter(a => enabled(a) && blockedUntil(a) !== null).length

    function enabled(account) {
        return account.status === "active" && account.schedulable;
    }

    function blockedUntil(account) {
        let until = Math.max(account.rate_limit_reset_at ?? 0, account.overload_until ?? 0,
            account.temp_unschedulable_until ?? 0);
        if (!stale(account.updated_at)) {
            for (const window of account.windows) {
                if (window.remaining_percent === 0 && window.reset_at !== null)
                    until = Math.max(until, window.reset_at);
            }
        }
        return until > now ? until : null;
    }

    function state(account) {
        if (account.status === "error")
            return "ошибка";
        if (account.status !== "active")
            return "выключен";
        if (!account.schedulable)
            return "пауза";
        const until = blockedUntil(account);
        if (until === null)
            return "включён";
        if (until === account.overload_until)
            return "перегрузка";
        if (until === account.temp_unschedulable_until)
            return "пауза";
        return "лимит";
    }

    function stale(updatedAt) {
        return updatedAt === null || now - updatedAt >= 300 || updatedAt > now + 60;
    }

    function age(updatedAt) {
        if (updatedAt === null)
            return "время неизвестно";
        const minutes = Math.max(0, Math.floor((now - updatedAt) / 60));
        if (minutes < 1)
            return "только что";
        if (minutes < 60)
            return minutes + " мин назад";
        if (minutes < 1440)
            return Math.floor(minutes / 60) + " ч " + minutes % 60 + " мин назад";
        return Math.floor(minutes / 1440) + " д назад";
    }

    function reset(resetAt) {
        if (resetAt === null)
            return "сброс неизвестен";
        if (resetAt <= now)
            return "ожидаем новый снимок";
        const minutes = Math.ceil((resetAt - now) / 60);
        if (minutes < 60)
            return "через " + minutes + " мин";
        if (minutes < 1440)
            return "через " + Math.floor(minutes / 60) + " ч " + minutes % 60 + " мин";
        return "через " + Math.floor(minutes / 1440) + " д " + Math.floor(minutes % 1440 / 60) + " ч";
    }

    Process {
        id: request

        command: [Quickshell.shellDir + "/scripts/ai-limits"]
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: errors }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = errors.text.trim() || "Не удалось получить квоты";
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
                root.error = "Некорректные данные квот";
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!request.running) request.running = true
    }
}
