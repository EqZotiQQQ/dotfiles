My personal dotfiles config

Window manager: ~Awesome~ Hyprland
Shell: Zsh
Screenlock: i3lock
Terminal emulator: Kitty/Terminator
Window switcher: Wofi
Screenshot tool: Flameshot


Used to mount disc with windows that contains icloud with obsidian
```bash
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable mount_disk.service
systemctl --user start mount_disk.service


systemctl --user daemon-reexec && \
systemctl --user daemon-reload && \
systemctl --user enable waybar_live_reload.service && \
systemctl --user start waybar_live_reload.service
```