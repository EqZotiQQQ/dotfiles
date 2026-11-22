import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("lua"), "Lua is required")
class WindowOpacityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        result = subprocess.run(
            ["lua", "-"],
            input='''
package.path = "./?.lua;" .. package.path
package.loaded.monitors = { list = function() return {} end }
package.loaded.layouts = { restore = function() end }
package.loaded.keybindings = true
local rules, configs = {}, {}
local function noop() end
hl = {
    monitor = noop, on = noop, env = noop, permission = noop,
    curve = noop, animation = noop, gesture = noop, layer_rule = noop,
    notification = { create = noop },
    window_rule = function(rule) table.insert(rules, rule) end,
    config = function(config) table.insert(configs, config) end,
}
dofile("hyprland.lua")
print(require("lib.json").encode({ rules = rules, configs = configs }))
''',
            cwd=ROOT / "home/.config/hypr",
            env=dict(os.environ, XDG_CONFIG_HOME=str(ROOT / "home/.config")),
            text=True, capture_output=True, check=True, timeout=10,
        )
        settings = json.loads(result.stdout)
        cls.rules = settings["rules"]
        cls.configs = settings["configs"]

    def opacity(self, window_class, title):
        opacity = (1.0, 1.0)
        for rule in self.rules:
            if "opacity" not in rule:
                continue
            window = {"class": window_class, "title": title}
            if all(re.fullmatch(pattern, window.get(key, ""))
                   for key, pattern in rule["match"].items()):
                opacity = tuple(float(value) for value in rule["opacity"].split())
        return opacity

    def test_kitty_is_translucent_regardless_of_foreground_command(self):
        for title in ("kitty", "~/projects", "nvim file.py", "vim file.py"):
            with self.subTest(title=title):
                self.assertEqual(self.opacity("kitty", title), (0.9, 0.8))

    def test_codex_desktop_uses_the_same_opacity(self):
        self.assertEqual(self.opacity("Chatgpt", "ChatGPT"), (0.9, 0.8))

    def test_dolphin_and_obsidian_use_the_same_opacity(self):
        for window_class in ("org.kde.dolphin", "md.obsidian.Obsidian"):
            with self.subTest(window_class=window_class):
                self.assertEqual(self.opacity(window_class, "Home"), (0.9, 0.8))

    def test_existing_editor_and_other_app_opacity_is_preserved(self):
        for window_class in ("code", "com.microsoft.VSCode"):
            self.assertEqual(self.opacity(window_class, "editor"), (0.9, 0.8))
        self.assertEqual(self.opacity("google-chrome", "kitty"), (1.0, 1.0))

    def test_window_blur_is_enabled(self):
        blur = {}
        for config in self.configs:
            blur.update(config.get("decoration", {}).get("blur", {}))
        self.assertTrue(blur["enabled"])
        self.assertGreater(blur["size"], 0)
        self.assertGreater(blur["passes"], 0)


if __name__ == "__main__":
    unittest.main()
