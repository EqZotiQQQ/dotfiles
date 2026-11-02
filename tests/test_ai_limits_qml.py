import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "home/.config/quickshell"


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the QML service check")
class QuotaServiceTests(unittest.TestCase):
    def test_failure_recovery_and_empty_accounts(self):
        with tempfile.TemporaryDirectory(prefix="ai-limits-test-") as directory:
            root = Path(directory)
            (root / "common").mkdir()
            (root / "services").mkdir()
            (root / "scripts").mkdir()
            shutil.copy(SOURCE / "common/Time.qml", root / "common/Time.qml")
            service = (SOURCE / "services/AiLimits.qml").read_text()
            (root / "services/AiLimits.qml").write_text(service.replace("interval: 60000", "interval: 300"))
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
    print("Сервер недоступен", file=sys.stderr)
    sys.exit(1)
if count == 3:
    print("{}")
else:
    print(json.dumps({"accounts": [] if count >= 5 else [{"remaining": 42 if count == 4 else 80}]}))
''')
            script.chmod(0o755)
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.services
ShellRoot {
    property int stage: 0
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    Timer {
        interval: 20; repeat: true; running: true
        onTriggered: {
            if (stage === 0 && AiLimits.loaded) {
                check(AiLimits.accounts[0].remaining === 80, "first snapshot");
                check(AiLimits.stale(null), "missing timestamp");
                check(AiLimits.stale(AiLimits.now - 301), "old timestamp");
                check(AiLimits.stale(AiLimits.now + 3600), "future timestamp");
                check(!AiLimits.stale(AiLimits.now), "fresh timestamp");
                check(AiLimits.reset(AiLimits.now - 1) === "ожидаем новый снимок", "expired window");
                check(AiLimits.reset(null) === "сброс неизвестен", "unknown reset");
                check(typeof AiLimits.state === "function", "account state helper");
                const a = {status: "active", schedulable: true, updated_at: AiLimits.now,
                    rate_limit_reset_at: null, overload_until: null, temp_unschedulable_until: null,
                    windows: [{remaining_percent: 80, reset_at: AiLimits.now + 3600}]};
                check(AiLimits.state(a) === "включён", "enabled does not claim confirmed availability");
                a.rate_limit_reset_at = AiLimits.now + 3600;
                a.overload_until = AiLimits.now + 60;
                check(AiLimits.state(a) === "лимит", "longest restriction determines status");
                check(AiLimits.blockedUntil(a) === AiLimits.now + 3600, "latest restriction deadline");
                a.rate_limit_reset_at = AiLimits.now - 60;
                check(AiLimits.state(a) === "перегрузка", "expired rate limit does not hide overload");
                a.overload_until = null;
                a.temp_unschedulable_until = AiLimits.now + 120;
                check(AiLimits.state(a) === "пауза", "temporary pause");
                a.temp_unschedulable_until = null;
                a.windows[0].remaining_percent = 0;
                check(AiLimits.state(a) === "лимит", "fresh exhausted quota");
                check(AiLimits.blockedUntil(a) === a.windows[0].reset_at, "quota reset deadline");
                a.updated_at = AiLimits.now - 600;
                check(AiLimits.state(a) === "включён", "old quota does not assert a current restriction");
                a.status = "error";
                check(AiLimits.state(a) === "ошибка" && !AiLimits.enabled(a), "account error");
                a.status = "disabled";
                check(AiLimits.state(a) === "выключен", "disabled account");
                a.status = "active"; a.schedulable = false;
                check(AiLimits.state(a) === "пауза" && !AiLimits.enabled(a), "manual scheduling pause");
                stage = 1;
            } else if (stage === 1 && AiLimits.error === "Сервер недоступен") {
                check(AiLimits.accounts[0].remaining === 80, "retain last snapshot on SSH failure");
                stage = 2;
            } else if (stage === 2 && AiLimits.error === "Некорректные данные квот") {
                check(AiLimits.accounts[0].remaining === 80, "retain last snapshot on bad data");
                stage = 3;
            } else if (stage === 3 && AiLimits.error === "") {
                check(AiLimits.accounts[0].remaining === 42, "recover with new quota");
                stage = 4;
            } else if (stage === 4 && AiLimits.accounts.length === 0) {
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
