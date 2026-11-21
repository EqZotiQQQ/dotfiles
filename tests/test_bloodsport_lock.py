import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required for the lockscreen check")
class BloodsportLockTests(unittest.TestCase):
    def test_empty_password_busy_guard_and_retry(self):
        for preset in ("bloodsport", "asiimov"):
            with self.subTest(preset=preset):
                self.check_lock(preset)

    def check_lock(self, preset):
        with tempfile.TemporaryDirectory(prefix="bloodsport-lock-") as directory:
            root = Path(directory)
            config = root / ".config"
            shutil.copytree(REPO / "home/.config/lockscreen/themes/bloodsport",
                            config / "lockscreen/themes/bloodsport")
            shutil.copytree(REPO / "home/.config/theme", config / "theme")
            (root / "Pictures/wallpapers").mkdir(parents=True)
            shutil.copy(REPO / "wallpapers" / f"{preset}.png", root / "Pictures/wallpapers")
            theme_path = config / "theme/theme.json"
            theme = json.loads(theme_path.read_text())
            palette = json.loads((config / "theme/presets" / f"{preset}.json").read_text())
            theme["colors"] = palette["colors"]
            theme["wallpaper"] = palette["wallpaper"]
            theme_path.write_text(json.dumps(theme))
            (root / "shell.qml").write_text('''import QtQuick
import Quickshell
ShellRoot {
    readonly property var sddm: fakeSddm
    readonly property var userModel: ({lastUser: "test-user"})
    readonly property var sessionModel: ({lastIndex: 0})
    QtObject {
        id: fakeSddm
        property int calls: 0
        signal loginFailed()
        function login(user, password, session) {
            check(user === "test-user" && password === "test-password" && session === 0,
                  "login arguments");
            calls++;
        }
    }
    readonly property string themePath: Quickshell.shellDir + "/.config/lockscreen/themes/bloodsport"
    readonly property var screen: themeLoader.item
    Loader { id: themeLoader; source: themePath + "/Main.qml"; width: 1280; height: 720 }
    function check(ok, message) {
        if (!ok) {
            console.error("ASSERTION", message);
            Qt.exit(1);
        }
    }
    function passwordInput(item) {
        if (item.echoMode !== undefined)
            return item;
        for (const child of item.children) {
            const found = passwordInput(child);
            if (found)
                return found;
        }
        return null;
    }
    function wallpaperImage(item) {
        if (item.fillMode !== undefined && item.source !== undefined)
            return item;
        for (const child of item.children) {
            const found = wallpaperImage(child);
            if (found)
                return found;
        }
        return null;
    }
    Timer {
        interval: 500; running: true
        onTriggered: {
            const wallpaper = wallpaperImage(screen);
            check(wallpaper !== null && wallpaper.status === Image.Ready, "wallpaper loaded");
            check(wallpaper.source.toString().endsWith("/" + Quickshell.env("THEME_TEST_WALLPAPER")), "selected preset wallpaper");
            const input = passwordInput(screen);
            check(input !== null, "password input exists");
            check(input.echoMode === TextInput.Password, "password is masked");
            screen.login();
            check(fakeSddm.calls === 0 && !screen.busy, "empty Enter never reaches PAM");
            input.text = "test-password";
            screen.login();
            check(fakeSddm.calls === 1 && screen.busy && !input.enabled, "pending authentication");
            screen.login();
            check(fakeSddm.calls === 1, "no duplicate authentication");
            fakeSddm.loginFailed();
            check(!screen.busy && screen.failed && input.enabled && input.text === "", "retry after failure");
            input.text = "test-password";
            screen.login();
            check(fakeSddm.calls === 2 && !screen.failed, "retry reaches authentication");
            console.log("BLOODSPORT_LOCK_PASSED");
            Qt.quit();
        }
    }
}
''')
            result = subprocess.run(
                ["qs", "--no-color", "--path", str(root)],
                env=dict(os.environ, HOME=str(root), XDG_CONFIG_HOME=str(config),
                         QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software",
                         THEME_TEST_WALLPAPER=f"{preset}.png"),
                text=True, capture_output=True, timeout=10,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("BLOODSPORT_LOCK_PASSED", output)
            self.assertNotIn("Failed to load", output)
            self.assertNotIn("ReferenceError", output)
            self.assertNotIn("TypeError", output)
            self.assertNotIn("Unable to assign", output)


if __name__ == "__main__":
    unittest.main()
