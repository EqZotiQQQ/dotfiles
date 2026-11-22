import json
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / "home/.local/bin/theme-apply"
PRESETS = sorted(path.stem for path in (REPO / "home/.config/theme/presets").glob("*.json"))


class ThemePresetTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="theme-presets-")
        self.addCleanup(self.directory.cleanup)
        self.home = Path(self.directory.name)
        self.config = self.home / ".config"
        for name in ("theme", "proctree", "kitty", "wofi", "lockscreen"):
            shutil.copytree(REPO / "home/.config" / name, self.config / name)
        (self.config / "hypr").mkdir()
        shutil.copy(REPO / "home/.config/hypr/hyprpaper.conf", self.config / "hypr")
        (self.home / "Pictures/wallpapers").mkdir(parents=True)
        for name in PRESETS:
            (self.home / "Pictures/wallpapers" / f"{name}.png").symlink_to(REPO / "wallpapers" / f"{name}.png")
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.config))
        self.outputs = [self.config / name for name in (
            "theme/theme.json", "proctree/config.yaml", "kitty/theme.conf", "wofi/style.css", "hypr/hyprpaper.conf", "theme/preset.json")]

    def select(self, name):
        (self.config / "theme/preset.json").write_text(json.dumps({"preset": name}))

    def run_apply(self, *args):
        return subprocess.run([sys.executable, SCRIPT, *args], env=self.env,
                              text=True, capture_output=True, timeout=10)

    def snapshot(self):
        return [path.read_bytes() for path in self.outputs]

    def test_roundtrip_changes_every_consumer_and_preserves_layout_and_symlinks(self):
        theme_path = self.config / "theme/theme.json"
        theme = json.loads(theme_path.read_text())
        theme["shape"]["gapsOut"] = 17
        theme["fonts"]["size"] = 19
        theme["widgetReveal"]["mode"] = "pressure"
        theme_path.write_text(json.dumps(theme))
        backing = self.home / "theme-source.json"
        theme_path.rename(backing)
        theme_path.symlink_to(backing)
        inode = backing.stat().st_ino
        self.select("bloodsport")
        result = self.run_apply("--files-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        baseline = self.snapshot()[:-1]

        self.select("asiimov")
        result = self.run_apply("--files-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        active = json.loads(theme_path.read_text())
        self.assertEqual(active["name"], "asiimov")
        self.assertEqual(active["colors"]["primary"], "#F47B20")
        self.assertEqual(active["wallpaper"], "asiimov.png")
        self.assertEqual(active["shape"], theme["shape"])
        self.assertEqual(active["fonts"], theme["fonts"])
        self.assertEqual(active["motion"], theme["motion"])
        self.assertEqual(active["widgetReveal"]["mode"], "pressure")
        self.assertTrue(theme_path.is_symlink())
        self.assertEqual(backing.stat().st_ino, inode)
        proc = (self.config / "proctree/config.yaml").read_text()
        self.assertIn("position: [-320, 20]", proc)
        self.assertIn("# --- Layer 1: processes", proc)
        self.assertIn("[0.9569, 0.4824, 0.1255]", proc)
        self.assertIn("#F47B20", (self.config / "kitty/theme.conf").read_text())
        self.assertIn("@define-color primary #F47B20;", (self.config / "wofi/style.css").read_text())
        self.assertIn("asiimov.png", (self.config / "hypr/hyprpaper.conf").read_text())

        self.select("bloodsport")
        result = self.run_apply("--files-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot()[:-1], baseline)

    def test_check_is_read_only(self):
        self.select("asiimov")
        before = self.snapshot()
        result = self.run_apply("--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Preset asiimov: valid", result.stdout)
        self.assertEqual(self.snapshot(), before)

    def test_named_presets_are_saved_and_apply_to_every_consumer(self):
        self.assertEqual(set(PRESETS), {"asiimov", "bloodsport", "vaporwave", "deep-ocean",
                                       "forest-copper", "graphite-lime", "burgundy-gold", "arctic"})
        selection = self.config / "theme/preset.json"
        selection.write_text(json.dumps({"preset": "asiimov", "preset_": "bloodsport"}))
        before = json.loads((self.config / "theme/theme.json").read_text())
        for name in PRESETS:
            with self.subTest(preset=name):
                result = self.run_apply(name, "--files-only")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(json.loads(selection.read_text()), {"preset": name, "preset_": "bloodsport"})
                palette = json.loads((self.config / "theme/presets" / f"{name}.json").read_text())
                active = json.loads((self.config / "theme/theme.json").read_text())
                self.assertEqual(active["colors"], palette["colors"])
                self.assertEqual(active["wallpaper"], palette["wallpaper"])
                self.assertEqual(active["spectrum"]["colors"], palette["spectrum"])
                for key in ("shape", "fonts", "motion", "bar", "opacity"):
                    self.assertEqual(active[key], before[key])
                self.assertIn(palette["wallpaper"], (self.config / "hypr/hyprpaper.conf").read_text())
                self.assertIn(palette["colors"]["primary"], (self.config / "kitty/theme.conf").read_text())
                snapshot = self.snapshot()
                self.assertEqual(self.run_apply("--files-only").returncode, 0)
                self.assertEqual(self.snapshot(), snapshot)

    def test_named_check_list_and_errors_do_not_change_selection(self):
        before = self.snapshot()
        result = self.run_apply("--list")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), PRESETS)
        result = self.run_apply("vaporwave", "--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Preset vaporwave: valid", result.stdout)
        self.assertNotEqual(self.run_apply("unknown", "--files-only").returncode, 0)
        self.assertEqual(self.snapshot(), before)

    @unittest.skipUnless(importlib.util.find_spec("gi"), "PyGObject and GTK 3 are required")
    def test_wofi_background_when_css_is_loaded_from_memory(self):
        for preset in PRESETS:
            with self.subTest(preset=preset):
                self.select(preset)
                result = self.run_apply("--files-only")
                self.assertEqual(result.returncode, 0, result.stderr)
                result = subprocess.run([sys.executable, "-c", '''
import json, sys
from pathlib import Path
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
if not Gtk.init_check()[0]:
    sys.exit(77)
provider = Gtk.CssProvider()
provider.load_from_data(Path(sys.argv[1]).read_bytes())
context = Gtk.StyleContext()
path = Gtk.WidgetPath()
path.append_type(Gtk.Window)
path.iter_set_object_name(0, "window")
context.set_path(path)
context.add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER)
color = context.get_property("background-color", Gtk.StateFlags.NORMAL)
print(json.dumps([color.red, color.green, color.blue, color.alpha]))
''', str(self.config / "wofi/style.css")], cwd=self.home,
                    text=True, capture_output=True, timeout=10)
                if result.returncode == 77:
                    self.skipTest("GTK requires a graphical session")
                self.assertEqual(result.returncode, 0, result.stderr)
                actual = json.loads(result.stdout)
                palette = json.loads((self.config / "theme/presets" / f"{preset}.json").read_text())
                surface = palette["colors"]["surface"]
                expected = [int(surface[i:i + 2], 16) / 255 for i in (1, 3, 5)] + [0.6]
                for value, wanted in zip(actual, expected):
                    self.assertAlmostEqual(value, wanted, places=5)

    def test_unknown_and_invalid_presets_do_not_change_files(self):
        for name in ("unknown", "../bloodsport"):
            with self.subTest(name=name):
                self.select(name)
                before = self.snapshot()
                result = self.run_apply("--files-only")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.snapshot(), before)
        self.select("asiimov")
        preset = self.config / "theme/presets/asiimov.json"
        data = json.loads(preset.read_text())
        data["colors"]["primary"] = "orange"
        preset.write_text(json.dumps(data))
        before = self.snapshot()
        result = self.run_apply("--files-only")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_missing_wallpaper_or_changed_proctree_schema_rejects_before_writes(self):
        self.select("asiimov")
        wallpaper = self.home / "Pictures/wallpapers/asiimov.png"
        wallpaper.unlink()
        before = self.snapshot()
        self.assertNotEqual(self.run_apply("--files-only").returncode, 0)
        self.assertEqual(self.snapshot(), before)
        wallpaper.symlink_to(REPO / "wallpapers/asiimov.png")
        proc = self.config / "proctree/config.yaml"
        proc.write_text(proc.read_text().replace("root_color:", "unknown_color:"))
        before = self.snapshot()
        result = self.run_apply("--files-only")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing proctree color settings", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_live_reload_uses_selected_wallpaper_and_reports_failures(self):
        binary_dir = self.home / ".local/bin"
        binary_dir.mkdir(parents=True)
        mock = binary_dir / "mock"
        mock.write_text(f"#!{sys.executable}\n" + '''import json, os, pathlib, sys
with open(os.environ["THEME_TEST_LOG"], "a") as log:
    log.write(json.dumps([pathlib.Path(sys.argv[0]).name, *sys.argv[1:]]) + "\\n")
if os.environ.get("THEME_TEST_FAIL"):
    print("simulated reload error", file=sys.stderr)
    sys.exit(7)
if sys.argv[1:] == ["monitors", "-j"]:
    print('[{"name": "DP-TEST"}]')
''')
        mock.chmod(0o755)
        for command in ("hyprctl", "pkill", "mako-theme"):
            (binary_dir / command).symlink_to(mock)
        log = self.home / "calls.jsonl"
        self.env.update(PATH=str(binary_dir), HYPRLAND_INSTANCE_SIGNATURE="test", THEME_TEST_LOG=str(log))
        self.select("bloodsport")
        result = self.run_apply("asiimov")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = [json.loads(line) for line in log.read_text().splitlines()]
        self.assertIn(["hyprctl", "hyprpaper", "wallpaper",
                       f"DP-TEST,{self.home}/Pictures/wallpapers/asiimov.png"], calls)
        self.assertIn(["pkill", "-USR1", "-x", "kitty"], calls)
        self.assertIn(["pkill", "-TERM", "-x", "proctree"], calls)
        self.assertTrue(any(call[:2] == ["hyprctl", "dispatch"] for call in calls))
        self.env["THEME_TEST_FAIL"] = "1"
        result = self.run_apply()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("simulated reload error", result.stderr)


if __name__ == "__main__":
    unittest.main()
