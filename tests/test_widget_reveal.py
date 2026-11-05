import json
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "home/.config/quickshell"
REVEAL_CONFIG = {
    "mode": "delay", "delayMs": 450, "pressureThreshold": 120, "fadeMs": 360, "gap": 20,
    "backdrop": {"color": "#242424", "opacity": 0.65, "padding": 16,
                 "radius": 18, "blur": True, "blurOpacity": 0.35},
}


@unittest.skipUnless(shutil.which("c++") and shutil.which("pkg-config"), "C++ and pkg-config are required")
class WidgetClipTests(unittest.TestCase):
    def test_blur_is_confined_to_widget_and_excludes_bars(self):
        flags = subprocess.run(["pkg-config", "--cflags", "--libs", "hyprutils"],
                               text=True, capture_output=True)
        if flags.returncode != 0:
            self.skipTest("Hyprutils development files are required")
        source = (SOURCE / "native/widget-edge.cpp").read_text()
        draw_functions = source[source.index("void drawBackdrop("):source.index("void renderWidgets(")]
        harness = Path(__file__).with_name("widget_clip.cpp").read_text()
        with tempfile.TemporaryDirectory(prefix="widget-clip-test-") as directory:
            root = Path(directory)
            (root / "test.cpp").write_text(harness.replace("// WIDGET_EDGE_DRAW_FUNCTIONS", draw_functions))
            compile_result = subprocess.run(
                ["c++", "-std=c++23", str(root / "test.cpp"), "-o", str(root / "test")]
                + shlex.split(flags.stdout), text=True, capture_output=True, timeout=30)
            self.assertEqual(compile_result.returncode, 0, compile_result.stdout + compile_result.stderr)
            result = subprocess.run([str(root / "test")], text=True, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("WIDGET_CLIP_CHECK_PASSED", result.stdout)


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the reveal check")
class WidgetRevealTests(unittest.TestCase):
    @unittest.skipUnless(os.environ.get("HYPRLAND_INSTANCE_SIGNATURE") and shutil.which("hyprctl"),
                         "A Hyprland session is required for native dispatch")
    def test_proctree_command_is_accepted_by_hyprland(self):
        plugins = json.loads(subprocess.check_output(["hyprctl", "plugin", "list", "-j"], text=True))
        if not any(plugin["name"] == "widget-edge" for plugin in plugins):
            self.skipTest("widget-edge must be loaded for the native command check")
        with tempfile.TemporaryDirectory(prefix="proctree-dispatch-test-") as directory:
            root = Path(directory)
            for name in ("common", "services", "fake", "scripts"):
                (root / name).mkdir()
            loader = root / "scripts/widget-edge"
            loader.write_text("#!/bin/sh\nexit 0\n")
            loader.chmod(0o755)
            service = (SOURCE / "services/WidgetReveal.qml").read_text()
            (root / "services/WidgetReveal.qml").write_text(
                service.replace("import Quickshell.Hyprland", "import qs.fake"))
            (root / "common/Theme.qml").write_text('''pragma Singleton
import QtQuick
import Quickshell
Singleton {
    property var json: ({widgetReveal: TEST_REVEAL_CONFIG})
}
'''.replace("TEST_REVEAL_CONFIG", json.dumps(REVEAL_CONFIG)))
            (root / "fake/Hyprland.qml").write_text('''pragma Singleton
import Quickshell
Singleton {
    signal rawEvent(var event)
    function dispatch(command) { console.log("REVEAL_COMMAND", command); }
}
''')
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.services
ShellRoot {
    Timer {
        interval: 20; running: true
        onTriggered: {
            WidgetReveal.loaded = true;
            WidgetReveal.revealWidgets("WIDGET-REVEAL-TEST", 0.5);
            WidgetReveal.revealWidgets("WIDGET-REVEAL-TEST", 0);
            Qt.quit();
        }
    }
}
''')
            result = subprocess.run(["qs", "--no-color", "--path", str(root)],
                                    env=dict(os.environ, QT_QPA_PLATFORM="offscreen"),
                                    text=True, capture_output=True, timeout=10)
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            commands = [line.split("REVEAL_COMMAND ", 1)[1] for line in log.splitlines()
                        if "REVEAL_COMMAND " in line]
            self.assertEqual(len(commands), 2, log)
            for command in commands:
                dispatch = subprocess.run(["hyprctl", "dispatch", command],
                                          text=True, capture_output=True, timeout=5)
                self.assertEqual(dispatch.returncode, 0, dispatch.stdout + dispatch.stderr)

    def test_proctree_follows_the_same_progress_and_monitor(self):
        with tempfile.TemporaryDirectory(prefix="proctree-reveal-test-") as directory:
            root = Path(directory)
            (root / "common").mkdir()
            (root / "services").mkdir()
            for name in ("EdgeRevealState.qml", "DesktopReveal.qml"):
                shutil.copy(SOURCE / "common" / name, root / "common")
            (root / "services/WidgetReveal.qml").write_text('''pragma Singleton
import Quickshell
Singleton {
    property bool valid: true
    property bool ready: true
    property var config: ({mode: "pressure", delayMs: 100, pressureThreshold: 100, fadeMs: 30})
    property var amounts: ({})
    property int sends: 0
    signal sample(string monitor, real upward)
    function revealWidgets(monitor, progress) {
        amounts[monitor] = progress;
        sends++;
    }
}
''')
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.common
import qs.services
ShellRoot {
    DesktopReveal { id: first; monitorName: "DP-1" }
    DesktopReveal { id: second; monitorName: "DP-2" }
    property int step: 0
    property int heldSends: 0
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    Timer {
        interval: 100; repeat: true; running: true
        onTriggered: {
            switch (step++) {
            case 0:
                WidgetReveal.sample("DP-1", 25);
                break;
            case 1:
                check(first.progress === 0.25, "partial reveal");
                check(WidgetReveal.amounts["DP-1"] === first.progress, "same opacity for proctree and QML");
                check(second.progress === 0, "other monitor stays below windows");
                heldSends = WidgetReveal.sends;
                break;
            case 7:
                check(WidgetReveal.sends > heldSends, "stationary reveal stays alive");
                WidgetReveal.sample("DP-2", 100);
                break;
            case 8:
                check(WidgetReveal.amounts["DP-1"] === 0, "old monitor resets");
                check(WidgetReveal.amounts["DP-2"] === 1, "new monitor reveals");
                WidgetReveal.ready = false;
                break;
            case 9:
                check(WidgetReveal.amounts["DP-2"] === 0, "detector failure hides proctree");
                WidgetReveal.ready = true;
                WidgetReveal.config = {mode: "delay", delayMs: 100, pressureThreshold: 100, fadeMs: 30};
                WidgetReveal.sample("DP-1", 0);
                break;
            case 12:
                check(first.progress === 1 && WidgetReveal.amounts["DP-1"] === 1, "delay reveals both widgets");
                WidgetReveal.sample("", 0);
                break;
            case 13:
                check(WidgetReveal.amounts["DP-1"] === 0, "leaving resets both widgets");
                console.log("PROCTREE_REVEAL_CHECK_PASSED");
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
            self.assertIn("PROCTREE_REVEAL_CHECK_PASSED", log)
            self.assertNotIn("ASSERTION", log)

    def test_valid_config_loads_detector_without_startup_error(self):
        with tempfile.TemporaryDirectory(prefix="widget-service-test-") as directory:
            root = Path(directory)
            for name in ("common", "services", "scripts"):
                (root / name).mkdir()
            shutil.copy(SOURCE / "services/WidgetReveal.qml", root / "services")
            (root / "common/Theme.qml").write_text('''pragma Singleton
import QtQuick
import Quickshell
Singleton {
    property var json: ({})
    Timer {
        interval: 20; running: true
        onTriggered: json = {widgetReveal: TEST_REVEAL_CONFIG}
    }
}
'''.replace("TEST_REVEAL_CONFIG", json.dumps(REVEAL_CONFIG)))
            for script in ("widget-edge", "notify-send"):
                path = root / "scripts" / script
                path.write_text("#!/bin/sh\nexit 0\n")
                path.chmod(0o755)
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.services
import qs.common
ShellRoot {
    property bool ready: WidgetReveal.valid
    property int step: 0
    property var invalid: [
        ["color", "not-a-color"], ["opacity", 1.5], ["padding", -1],
        ["radius", -1], ["blur", "yes"], ["blurOpacity", -0.1], ["gap", -1]
    ]
    Timer {
        interval: 100; running: true; repeat: true
        onTriggered: {
            const expectValid = step === 0 || step === invalid.length + 1;
            if (expectValid ? (!WidgetReveal.valid || !WidgetReveal.loaded || WidgetReveal.error !== "")
                            : (WidgetReveal.valid || WidgetReveal.error === "")) {
                console.error("ASSERTION", "backdrop validation/recovery", step, WidgetReveal.error);
                Qt.exit(1);
                return;
            }
            if (step > invalid.length) {
                console.log("WIDGET_SERVICE_CHECK_PASSED");
                Qt.quit();
                return;
            }
            const next = TEST_REVEAL_CONFIG;
            if (step < invalid.length) {
                if (invalid[step][0] === "gap")
                    next.gap = invalid[step][1];
                else
                    next.backdrop[invalid[step][0]] = invalid[step][1];
            }
            Theme.json = {widgetReveal: next};
            step++;
        }
    }
}
'''.replace("TEST_REVEAL_CONFIG", json.dumps(REVEAL_CONFIG)))
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen",
                       PATH=str(root / "scripts") + os.pathsep + os.environ["PATH"])
            env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
            result = subprocess.run(["qs", "--no-color", "--path", str(root)],
                                    env=env, text=True, capture_output=True, timeout=10)
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            self.assertIn("WIDGET_SERVICE_CHECK_PASSED", log)
            self.assertNotIn("ASSERTION", log)

    @unittest.skipUnless(os.environ.get("WAYLAND_DISPLAY"), "A Wayland session is required for layer windows")
    def test_limits_follow_proctree_bounds_and_spacing(self):
        with tempfile.TemporaryDirectory(prefix="widget-overlay-test-") as directory:
            root = Path(directory)
            shutil.copytree(SOURCE / "common", root / "common")
            shutil.copytree(SOURCE / "limits", root / "limits")
            (root / "services").mkdir()
            (root / "services/AiLimits.qml").write_text('''pragma Singleton
import Quickshell
Singleton {
    property bool loaded: true
    property var accounts: []
    property var providers: [{name: "Codex", accounts: []}, {name: "Claude", accounts: []}]
    property bool fetching: false
    property int fetchInSeconds: 60
    property string error: ""
}
''')
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
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.limits
import qs.services
ShellRoot {
    Limits { id: desktop; modelData: Quickshell.screens[0] }
    function bounds(height) {
        const next = {};
        next[desktop.screen.name] = {x: 100, y: 40, width: 600, height: height};
        WidgetReveal.proctreeBounds = next;
    }
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    property int step: 0
    Timer {
        interval: 80; repeat: true; running: true
        onTriggered: {
            if (step === 0) {
                bounds(300);
            } else if (step === 1) {
                check(desktop.visible, "AI Limits shown after proctree geometry arrives");
                check(desktop.margins.left + desktop.width === 716, "right backdrop edges aligned");
                check(desktop.margins.top === 376, "20px gap between outer boxes");
                bounds(450);
                WidgetReveal.backdrop = {padding: 24};
                WidgetReveal.config = {gap: 32};
            } else if (step === 2) {
                check(desktop.margins.left + desktop.width === 724, "padding preserves right alignment");
                check(desktop.margins.top === 546, "growing proctree never overlaps AI Limits");
                check(desktop.contentItem.opacity === 1, "source buffer remains available for the native overlay");
                WidgetReveal.proctreeBounds = {};
            } else {
                check(!desktop.visible, "missing geometry does not use stale coordinates");
                console.log("WIDGET_LAYOUT_CHECK_PASSED");
                Qt.quit();
            }
            step++;
        }
    }
}
''')
            result = subprocess.run(
                ["qs", "--no-color", "--path", str(root)],
                env=dict(os.environ, QT_QPA_PLATFORM="wayland"),
                text=True, capture_output=True, timeout=10,
            )
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            self.assertIn("WIDGET_LAYOUT_CHECK_PASSED", log)
            self.assertNotIn("ASSERTION", log)
            self.assertNotIn("Unable to assign", log)

    def test_delay_pressure_monitor_change_and_reset(self):
        with tempfile.TemporaryDirectory(prefix="widget-reveal-test-") as directory:
            root = Path(directory)
            shutil.copy(SOURCE / "common/EdgeRevealState.qml", root)
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
ShellRoot {
    property int step: 0
    function check(condition, message) {
        if (!condition) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    EdgeRevealState {
        id: state
        monitorName: "DP-1"
        mode: "delay"
        delayMs: 150
        pressureThreshold: 100
        fadeMs: 30
    }
    Timer {
        interval: 70; repeat: true; running: true
        onTriggered: {
            switch (step++) {
            case 0:
                state.sample("DP-1", 500);
                check(state.progress === 0, "delay does not reveal on arrival");
                break;
            case 1:
                check(state.progress === 0, "wait for delay");
                state.sample("DP-2", 0);
                break;
            case 2:
                check(state.progress === 0, "leaving cancels delay");
                state.sample("DP-1", 0);
                break;
            case 3:
            case 4:
                state.sample("DP-1", 0);
                break;
            case 5:
                check(state.progress === 1, "stationary edge reveals after delay");
                state.sample("", 0);
                check(state.progress > 0, "hide is animated");
                break;
            case 6:
                check(state.progress === 0, "leave returns to desktop");
                state.mode = "pressure";
                state.sample("DP-1", 0);
                break;
            case 7:
                check(state.progress === 0, "pressure ignores dwell time");
                state.sample("DP-1", 25);
                break;
            case 8:
                check(Math.abs(state.progress - 0.25) < 0.001, "partial pressure");
                state.sample("DP-1", 25);
                break;
            case 9:
                check(Math.abs(state.progress - 0.5) < 0.001, "pressure accumulates");
                state.sample("DP-1", 1000);
                break;
            case 10:
                check(state.progress === 1, "pressure clamps at full reveal");
                state.sample("DP-2", 100);
                break;
            case 11:
                check(state.progress === 0, "other monitor hides this widget");
                state.sample("DP-1", 0);
                break;
            case 12:
                check(state.progress === 0, "return starts with fresh pressure");
                state.sample("DP-1", 50);
                state.mode = "delay";
                break;
            case 13:
                check(state.progress === 0, "mode change cancels pressure");
                state.sample("DP-1", 0);
                state.enabled = false;
                break;
            case 14:
            case 15:
                state.sample("DP-1", 100);
                break;
            case 16:
                check(state.progress === 0, "disabled detector cannot reveal");
                console.log("WIDGET_REVEAL_CHECK_PASSED");
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
            self.assertIn("WIDGET_REVEAL_CHECK_PASSED", log)
            self.assertNotIn("ASSERTION", log)


if __name__ == "__main__":
    unittest.main()
