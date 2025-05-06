My personal dotfiles config

Window manager: Awesome
Shell: Zsh
Screenlock: i3lock
Terminal emulator: Kitty/Terminal
Window switcher: Rofi
Lock: i3lock
Screenshot tool: Flameshot


Used to mount disc with windows that contains icloud with obsidian
```bash
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable mount_disk.service
systemctl --user start mount_disk.service
```