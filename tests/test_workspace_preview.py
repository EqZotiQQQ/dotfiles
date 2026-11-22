import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "home/.config/quickshell"


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the preview check")
class WorkspacePreviewTests(unittest.TestCase):
    def test_workspace_preview_interactions(self):
        with tempfile.TemporaryDirectory(prefix="workspace-preview-test-") as directory:
            root = Path(directory)
            for name in ("common", "bar", "fixtures", "theme"):
                (root / name).mkdir()
            for name in ("Theme", "ThemeAnim", "Strip", "StyledText"):
                shutil.copy(SOURCE / "common" / (name + ".qml"), root / "common")
            for path in (SOURCE / "bar").glob("*Workspace*.qml"):
                (root / "bar" / path.name).write_text(path.read_text().replace(
                    "import Quickshell.Hyprland", "import qs.fixtures"))
            (root / "theme/theme.json").write_text("{}")
            fixtures = {
                "HyprlandMonitor": "property var activeWorkspace: null",
                "HyprlandWorkspace": '''property int id: 1
                    property var monitor: null
                    property var toplevels: QtObject { property var values: [] }
                    property int activations: 0
                    function activate() { activations++; }''',
                "HyprlandToplevel": '''property var workspace: null
                    property var lastIpcObject: ({})
                    property var wayland: null''',
            }
            for name, body in fixtures.items():
                (root / "fixtures" / (name + ".qml")).write_text(
                    "import QtQuick\nQtObject { " + body + " }\n")
            (root / "fixtures/Hyprland.qml").write_text('''pragma Singleton
import QtQuick
import Quickshell
Singleton {
    property var workspaces: QtObject { property var values: [] }
    property var toplevels: QtObject { property var values: [] }
    property int refreshes: 0
    function refreshToplevels() { refreshes++; }
    function dispatch(command) {}
}
''')
            shutil.copy(Path(__file__).with_name("workspace_preview.qml"), root / "shell.qml")
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen", XDG_CONFIG_HOME=str(root))
            env.pop("WAYLAND_DISPLAY", None)
            env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
            result = subprocess.run(["qs", "--no-color", "--path", str(root)],
                                    env=env, text=True, capture_output=True, timeout=45)
            log = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, log)
            for error in ("ASSERTION", "TypeError", "ReferenceError", "Binding loop", "Failed to load"):
                self.assertNotIn(error, log)
            self.assertEqual(log.count("WORKSPACE_PREVIEW_PASSED"), 6, log)


if __name__ == "__main__":
    unittest.main()
