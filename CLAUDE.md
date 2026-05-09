# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for Manjaro Linux. Window manager: Hyprland (migrated from AwesomeWM). Shell: Zsh with Zinit + Powerlevel10k. Editor: Neovim (AstroNvim).

The repo has two config trees:
- `home/` — current active configs, symlinked into `~`
- `home.legacy/` — archived configs (AwesomeWM era, X11-based), kept for reference

## Setup

**Entry point** — `init_os_modules.sh` auto-detects the OS and wires everything together:

```bash
# Fresh Manjaro install — desktop profile + symlinks:
./init_os_modules.sh --profile desktop --symlinks

# Fresh Ubuntu install — workstation + build from source + symlinks:
./init_os_modules.sh --os ubuntu --profile workstation --open-source --symlinks

# Only set up dotfile symlinks (overwrite existing):
./init_os_modules.sh --symlinks --overwrite

# Individual components instead of a profile:
./init_os_modules.sh --wm --editor --symlinks
```

**`install/`** — все скрипты установки и менеджер симлинков:
- `install/manjaro.sh` — paru-based; profiles: `minimal`, `desktop`, `full`
- `install/ubuntu.sh` — apt-based; profiles: `minimal`, `workstation`, `full`
- `install/open_source.sh` — builds from source: `--i3lock`, `--rofi`, `--picom`
- `install/main.py` + `install/app_settings.py` — менеджер симлинков

**Симлинки напрямую** — `install/main.py` управляет `home/` → `~` и `etc/` → `/etc`:

```bash
python install/main.py -s        # dry-run
python install/main.py -s -f     # применить
python install/main.py -s -f -o  # применить + перезаписать существующие
```

Новые файлы в `home/.config/eww/scripts/` симлинкуются по одному — добавить вручную через `ln -s`.

## Hyprland

Конфиги в `home/.config/hypr/`:
- `hyprland.conf` — основной конфиг; keybindings вынесены в `keybindings.conf` (source'd)
- `keybindings.conf` — все бинды клавиш
- `hyprpaper.conf` — обои
- `hypridle.conf` — автоблокировка
- `hyprlock.conf` — экран блокировки

**Автозапуск** (exec-once в hyprland.conf):
```
hyprpaper, hypridle, eww daemon, mako, hyprpolkitagent
sleep 1 && eww open bar && eww open bar2
```

## eww (статусбар)

Конфиги в `home/.config/eww/`:
- `eww.yuck` — все виджеты и окна
- `eww.scss` — стили (Catppuccin Mocha)

**Окна eww:**
- `bar` (monitor 1) + `bar2` (monitor 0) — топ-бары с воркспейсами, клоком, модулями
- Popup-окна для каждого модуля: `cpu-popup-window`, `temp-popup-window`, `ram-popup-window`, `sink-popup-window`, `power-popup-window`

**Поллинг (интервалы разнесены чтобы не бить залпом):**
- 1s: `clock-time`, `volume-text`, `cpu-usage`, `temperature`, `memory-pct`, `cpu-cores`
- 2s: `dnd-status`
- 3s: `network-text`
- 5s: `language`
- 60s: `clock-date`

**Скрипты** в `home/.config/eww/scripts/`:
- `active-window` — заголовок активного окна (Hyprland socket)
- `workspaces` — список воркспейсов с состоянием
- `volume` — громкость (wpctl), поддерживает up/down/mute
- `audio-sinks` — список аудио-устройств (wpctl)
- `audio-sink-select` — переключение sink
- `cpu` — загрузка CPU (читает /proc/stat дважды с sleep 0.3)
- `cpu-cores` — загрузка по ядрам + топ процессов (кэш в /tmp)
- `memory-details` — RAM, cache, swap, топ процессов
- `temperatures` — температуры сенсоров
- `network` — интерфейс, скорость ↓↑, Wi-Fi сигнал (iw)
- `popup-open`, `popup-toggle`, `popup-hover-out`, `popup-auto-close` — управление popup-окнами

**Перезагрузка eww:** `eww reload`

## Zsh config structure

`home/.zshenv` → sets `ZDOTDIR=~/.config/zsh` and sources `~/.config/zsh/.zshenv`.

All zsh config lives in `home/.config/zsh/`:
- `.zshrc` — plugins (Zinit), prompt (p10k), sources all `aliases/*`
- `settings/plugins.zsh` — Zinit plugin declarations
- `settings/bindings.zsh` — key bindings
- `aliases/01_standard_app_replacement.zsh` — modern CLI replacements: `exa`→`ls`, `bat`→`cat`, `duf`→`df`, `rg`→`grep`, `nvim`→`vim`
- `aliases/03_git.zsh` — git shortcuts (`gs`, `gaa`, `gps`, `gpl`, `gd`, `gl`, `gc`, `gcm`, etc.)

## Scripts

`home/.local/bin/` — shell scripts used by the WM and keybindings:
- `lock_screen.sh` — i3lock wrapper
- `mako-dnd` — toggle do-not-disturb mode (mako)
- `mako-history` — показать историю уведомлений
- `mount_disk.sh` — mounts Windows disk (iCloud/Obsidian access)
- `brightness_handle.sh` — brightness control
- `hypr-keys` — показать список кейбайндингов
- `hypr-reload` — перезагрузить Hyprland конфиг
- `workspaces`, `ws-move`, `ws-switch` — управление воркспейсами
- `waybar_live_reload.sh` / `waybar-reload` / `waybar-watch` — waybar утилиты (не используются, eww заменил waybar)

## Submodule

`home/.config/awesome/cosy` — AwesomeWM widget library (legacy, not used in current Hyprland setup).
