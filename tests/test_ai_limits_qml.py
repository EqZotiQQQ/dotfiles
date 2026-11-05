from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "home/.config/quickshell"


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the QML service check")
class QuotaServiceTests(unittest.TestCase):
    @unittest.skipUnless(os.environ.get("WAYLAND_DISPLAY"), "A Wayland session is required for the widget check")
    def test_english_provider_layout_used_percent_and_cache_tokens(self):
        now = int(datetime.now(timezone.utc).timestamp())
        accounts = []
        for index, provider in enumerate(("Codex", "Claude")):
            accounts.append({
                "id": index + 1, "provider": provider, "name": "Alex Example" if provider == "Codex" else "ClaudeAccount1",
                "status": "active", "schedulable": True, "updated_at": now,
                "last_used_at": now - 120 if index == 0 else None,
                "rate_limit_reset_at": None, "overload_until": None, "temp_unschedulable_until": None,
                "cache_miss_tokens": 314 if index == 0 else None,
                "cache_hit_tokens": 27904 if index == 0 else None,
                "windows": [
                    {"label": "5h", "used_percent": 83.5 if index == 0 else None, "reset_at": now + 3600 if index == 0 else None},
                    {"label": "7d", "used_percent": 40 if index == 0 else None, "reset_at": now + 86400 if index == 0 else None},
                ],
            })
        with tempfile.TemporaryDirectory(prefix="ai-limits-layout-") as directory:
            root = Path(directory)
            shutil.copytree(SOURCE / "common", root / "common")
            shutil.copytree(SOURCE / "limits", root / "limits")
            (root / "services").mkdir()
            shutil.copy(SOURCE / "services/AiLimits.qml", root / "services")
            (root / "services/WidgetReveal.qml").write_text('''pragma Singleton
import Quickshell
Singleton {
    property bool valid: true
    property bool ready: true
    property var config: ({gap: 20})
    property var backdrop: ({padding: 16})
    property var proctreeBounds: ({})
}
''')
            (root / "scripts").mkdir()
            script = root / "scripts/ai-limits"
            script.write_text("#!/usr/bin/env python3\nprint(" + repr(json.dumps({"accounts": accounts})) + ")\n")
            script.chmod(0o755)
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.limits
import qs.services
ShellRoot {
    Limits { id: widget; modelData: Quickshell.screens[0] }
    property int step: 0
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    function texts(item) {
        let result = typeof item.text === "string" ? [item.text] : [];
        for (const child of item.children)
            result = result.concat(texts(child));
        return result;
    }
    Timer {
        interval: 40; repeat: true; running: true
        onTriggered: {
            if (!AiLimits.loaded)
                return;
            if (step++ === 0) {
                const bounds = {};
                bounds[widget.screen.name] = {x: 100, y: 20, width: 500, height: 100};
                WidgetReveal.proctreeBounds = bounds;
                return;
            }
            const labels = texts(widget.contentItem);
            for (const label of ["AI Limits", "Codex", "Alex Example", "Claude", "ClaudeAccount1",
                                  "5h used: 83.5%", "7d used: 40%", "5h used: N/A", "Reset in: N/A"])
                check(labels.includes(label), "missing label: " + label);
            check(labels.some(t => t.startsWith("Last invoked:") && t.includes("Cache miss: 314")
                && t.includes("Cache hit: 27.9k tokens")), "cache metrics belong to the invocation row");
            check(labels.some(t => t.startsWith("Fetch in: ")), "next fetch countdown");
            check(!/[А-Яа-яЁё]/.test(labels.join(" ")), "all widget copy is English");
            check(!labels.some(t => /remaining|left/.test(t)), "used percentages only");
            console.log("AI_LIMITS_LAYOUT_PASSED");
            Qt.quit();
        }
    }
}
''')
            result = subprocess.run(["qs", "--no-color", "--path", str(root)],
                                    env=dict(os.environ, QT_QPA_PLATFORM="wayland"),
                                    text=True, capture_output=True, timeout=10)
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            self.assertIn("AI_LIMITS_LAYOUT_PASSED", log)
            self.assertNotIn("ASSERTION", log)
            self.assertNotIn("TypeError", log)

    def test_failure_recovery_and_empty_accounts(self):
        with tempfile.TemporaryDirectory(prefix="ai-limits-test-") as directory:
            root = Path(directory)
            (root / "services").mkdir()
            (root / "scripts").mkdir()
            service = (SOURCE / "services/AiLimits.qml").read_text()
            (root / "services/AiLimits.qml").write_text(service.replace("interval: 60000", "interval: 600").replace("interval: 1000", "interval: 50"))
            script = root / "scripts/ai-limits"
            script.write_text('''#!/usr/bin/env python3
import json
from pathlib import Path
import sys
path = Path(__file__).parent / "calls"
with path.open("a") as stream:
    stream.write("call\\n")
count = len(path.read_text().splitlines())
if count == 2:
    print("Server unavailable", file=sys.stderr)
    sys.exit(1)
if count == 3:
    print("{}")
else:
    print(json.dumps({"accounts": [] if count >= 5 else [{"provider": "Codex", "windows": [{"used_percent": 42 if count == 4 else 80}]}]}))
''')
            script.chmod(0o755)
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.services
ShellRoot {
    property int stage: 0
    property bool countedDown: false
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    Timer {
        interval: 20; repeat: true; running: true
        onTriggered: {
            if (AiLimits.loaded && !AiLimits.fetching && AiLimits.fetchInSeconds === 0) countedDown = true;
            if (stage === 0 && AiLimits.loaded) {
                check(AiLimits.accounts[0].windows[0].used_percent === 80, "first snapshot");
                check(AiLimits.providers[0].name === "Codex" && AiLimits.providers[0].accounts.length === 1, "Codex group");
                check(AiLimits.providers[1].name === "Claude" && AiLimits.providers[1].accounts.length === 0, "Claude group remains visible");
                check(AiLimits.tokens(null) === "N/A" && AiLimits.tokens(0) === "0", "missing cache is not zero");
                check(AiLimits.tokens(27904) === "27.9k", "compact token count");
                check(AiLimits.age(null) === "N/A", "missing invocation");
                check(AiLimits.stale(null), "missing timestamp");
                check(AiLimits.stale(AiLimits.now - 301), "old timestamp");
                check(AiLimits.stale(AiLimits.now + 3600), "future timestamp");
                check(!AiLimits.stale(AiLimits.now), "fresh timestamp");
                check(AiLimits.reset(AiLimits.now - 1) === "Awaiting update", "expired window");
                check(AiLimits.reset(null) === "N/A", "unknown reset");
                check(typeof AiLimits.state === "function", "account state helper");
                const a = {status: "active", schedulable: true, updated_at: AiLimits.now,
                    rate_limit_reset_at: null, overload_until: null, temp_unschedulable_until: null,
                    windows: [{used_percent: 80, reset_at: AiLimits.now + 3600}]};
                check(AiLimits.state(a) === "Active", "enabled does not claim confirmed availability");
                a.rate_limit_reset_at = AiLimits.now + 3600;
                a.overload_until = AiLimits.now + 60;
                check(AiLimits.state(a) === "Limited", "longest restriction determines status");
                check(AiLimits.blockedUntil(a) === AiLimits.now + 3600, "latest restriction deadline");
                a.rate_limit_reset_at = AiLimits.now - 60;
                check(AiLimits.state(a) === "Overloaded", "expired rate limit does not hide overload");
                a.overload_until = null;
                a.temp_unschedulable_until = AiLimits.now + 120;
                check(AiLimits.state(a) === "Paused", "temporary pause");
                a.temp_unschedulable_until = null;
                a.windows[0].used_percent = 100;
                check(AiLimits.state(a) === "Limited", "fresh exhausted quota");
                check(AiLimits.blockedUntil(a) === a.windows[0].reset_at, "quota reset deadline");
                a.updated_at = AiLimits.now - 600;
                check(AiLimits.state(a) === "Active", "old quota does not assert a current restriction");
                a.status = "error";
                check(AiLimits.state(a) === "Error", "account error");
                a.status = "disabled";
                check(AiLimits.state(a) === "Disabled", "disabled account");
                a.status = "active"; a.schedulable = false;
                check(AiLimits.state(a) === "Paused", "manual scheduling pause");
                stage = 1;
            } else if (stage === 1 && AiLimits.error === "Server unavailable") {
                check(AiLimits.accounts[0].windows[0].used_percent === 80, "retain last snapshot on SSH failure");
                stage = 2;
            } else if (stage === 2 && AiLimits.error === "Invalid quota data") {
                check(AiLimits.accounts[0].windows[0].used_percent === 80, "retain last snapshot on bad data");
                stage = 3;
            } else if (stage === 3 && AiLimits.error === "") {
                check(AiLimits.accounts[0].windows[0].used_percent === 42, "recover with new quota");
                stage = 4;
            } else if (stage === 4 && AiLimits.accounts.length === 0) {
                check(countedDown, "fetch countdown advances between requests");
                console.log("AI_LIMITS_CHECK_PASSED");
                Qt.quit();
            }
        }
    }
}
''')
            result = subprocess.run(
                ["qs", "--no-color", "--path", str(root)],
                env=dict(os.environ, QT_QPA_PLATFORM="offscreen"),
                text=True, capture_output=True, timeout=10,
            )
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            self.assertIn("AI_LIMITS_CHECK_PASSED", log)
            self.assertNotIn("ASSERTION", log)
            self.assertEqual((root / "scripts/calls").read_text().count("call"), 5)


if __name__ == "__main__":
    unittest.main()
