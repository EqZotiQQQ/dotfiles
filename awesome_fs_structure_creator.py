#!/bin/python3

import pathlib
import os

base_dir = f"{os.environ['HOME']}/awesome_cfg"

structure = {
    "": ["rc.lua", "config.lua", "theme.lua"],
    "keys": ["global.lua", "client.lua"],
    "rules": ["init.lua"],
    "signals": ["init.lua"],
    "widgets": ["clock.lua", "battery.lua", "volume.lua"],
    "layout": ["init.lua"],
    "ui": ["bar.lua", "menu.lua", "notifications.lua"],
    "autostart": ["apps.lua"],
    "lib": ["helpers.lua"],
    "themes/default/icons": [],
    "themes/default": ["theme.lua"],
    "themes/dark": ["theme.lua"],
}

file_contents = {
    "rc.lua": '-- Main config loader\nrequire("config")\nrequire("theme")\nrequire("keys.global")\nrequire("rules")\nrequire("signals")\nrequire("ui.bar")\nrequire("autostart.apps")\n',
    "config.lua": '-- Basic configuration\nterminal = "alacritty"\nbrowser = "firefox"\nmodkey = "Mod4"\n',
    "theme.lua": '-- Theme loader\nbeautiful.init("~/.config/awesome/themes/default/theme.lua")\n',
    "keys/global.lua": '-- Global keybindings\n',
    "keys/client.lua": '-- Client keybindings\n',
    "rules/init.lua": '-- Window rules\n',
    "signals/init.lua": '-- Signals handling\n',
    "widgets/clock.lua": '-- Clock widget\n',
    "widgets/battery.lua": '-- Battery widget\n',
    "widgets/volume.lua": '-- Volume widget\n',
    "layout/init.lua": '-- Layouts\n',
    "ui/bar.lua": '-- Wibar configuration\n',
    "ui/menu.lua": '-- Main menu\n',
    "ui/notifications.lua": '-- Notification rules\n',
    "autostart/apps.lua": '-- Autostart applications\n',
    "lib/helpers.lua": '-- Helper functions\n',
    "themes/default/theme.lua": '-- Default theme\n',
    "themes/dark/theme.lua": '-- Dark theme\n',
}

for folder, files in structure.items():
    dir_path = pathlib.Path(base_dir) / folder
    dir_path.mkdir(parents=True, exist_ok=True)
    for file in files:
        file_path = dir_path / file
        content_key = pathlib.Path(folder) / file if folder else file
        with open(file_path, "w") as f:
            f.write(file_contents.get(content_key, "-- placeholder\n"))


