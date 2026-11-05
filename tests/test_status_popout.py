import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "home/.config/quickshell"


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the popout check")
class StatusPopoutTests(unittest.TestCase):
    def run_qml_test(self, filename):
        with tempfile.TemporaryDirectory(prefix="status-popout-test-") as directory:
            root = Path(directory)
            for name in ("common", "bar/popouts", "services", "theme"):
                (root / name).mkdir(parents=True)
            for name in ("Theme", "ThemeAnim", "Icons", "Strip", "StyledText", "Time"):
                shutil.copy(SOURCE / "common" / (name + ".qml"), root / "common")
            for name in ("StatusIsland", "Chip"):
                shutil.copy(SOURCE / "bar" / (name + ".qml"), root / "bar")
            (root / "theme/theme.json").write_text("{}")
            services = {
                "Cpu": "property int usage: 20",
                "Sensors": "property int cpuTemp: 45",
                "Memory": "property int usedPct: 35",
                "Audio": "property bool muted: false; property real volume: 0.5",
                "Network": '''property string iface: "eth0"; property bool wireless: false
                    property real rx: 0; property real tx: 0
                    function fmt(value) { return "0"; }''',
                "Wireless": '''property var devices: []; property var bluetooth: []
                    property var weakest: null
                    function icon(kind) { return ""; }''',
                "Mako": "property bool dnd: false; property int unread: 0",
                "Keyboard": 'property string layout: "EN"',
                "Media": "property var player: null",
            }
            for name, body in services.items():
                (root / "services" / (name + ".qml")).write_text(
                    "pragma Singleton\nimport Quickshell\nSingleton { " + body + " }\n")
            for path in (SOURCE / "bar/popouts").glob("*.qml"):
                (root / "bar/popouts" / path.name).write_text('''import QtQuick
Item {
    property real preferredWidth: 400
    implicitHeight: 240
    property var item: null
    signal done()
}
''')
            shutil.copy(Path(__file__).with_name(filename), root / "shell.qml")
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen", XDG_CONFIG_HOME=str(root))
            env.pop("WAYLAND_DISPLAY", None)
            env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
            result = subprocess.run(["qs", "--no-color", "--path", str(root)],
                                    env=env, text=True, capture_output=True, timeout=45)
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            self.assertNotIn("ASSERTION", log)
            self.assertNotIn("TypeError", log)
            self.assertNotIn("Binding loop", log)
            return log

    def test_popout_geometry_and_motion(self):
        log = self.run_qml_test("status_popout.qml")
        self.assertEqual(log.count("POPOUT_ORIGIN_PASSED"), 8, log)
        self.assertIn("POPOUT_EASING_PASSED", log)
        self.assertEqual(log.count("POPOUT_HANDOFF_PASSED"), 4, log)
        self.assertIn("POPOUT_SCREEN_BOUNDARY_PASSED", log)
        self.assertIn("POPOUT_INTERRUPTION_PASSED", log)

    def test_popout_hover_and_leave(self):
        log = self.run_qml_test("status_popout_hover.qml")
        self.assertEqual(log.count("POPOUT_HOVER_PASSED"), 6, log)


if __name__ == "__main__":
    unittest.main()
