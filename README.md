My personal dotfiles config

Window manager: ~Awesome~ Hyprland
Shell: Zsh
Screenlock: i3lock
Terminal emulator: Kitty/Terminator
Window switcher: Wofi
Screenshot tool: Flameshot


## Cava (eww bottom panel)

Визуализатор аудио отображается в нижней панели eww в виде вертикальных баров.

**Как работает:**
1. `cava` читает аудио через PipeWire (`source = auto`) и выводит высоты 40 баров в stdout в формате `0;3;7;...;2;\n`
2. Скрипт `~/.config/eww/scripts/cava` конвертирует каждую строку в JSON-массив `[0,3,7,...,2]` и передаёт в eww через `deflisten`
3. eww рендерит массив как набор `box`-элементов с переменной высотой (`bar * 3px`)
4. Если cava падает (потеря аудио-источника), скрипт перезапускает её через 0.1s без задержки со стороны eww

**Файлы:**
- `home/.config/eww/cava.ini` — конфиг cava (40 баров, 60fps, PipeWire)
- `home/.config/eww/scripts/cava` — скрипт-конвертер с restart-циклом
- `home/.config/eww/eww.yuck` — `deflisten cava-bars` + `cava-widget`
- `home/.config/eww/eww.scss` — стили баров (градиент `$mauve` → `$blue`)

**Запуск панели:**
```bash
eww open bottom-panel
```

---

## Монтирование диска с Windows

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