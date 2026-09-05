# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.


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
python install/main.py --status  # что разошлось между репо и ~ (exit 1 если есть расхождения)
python install/main.py -s        # dry-run
python install/main.py -s -f     # применить
python install/main.py -s -f -o  # применить + перезаписать существующие
```

`--status` классифицирует каждый файл: `linked`, `missing`, `differs` (реальный файл, содержимое разошлось),
`copy` (реальный файл, содержимое совпадает), `wrong-link`, `broken-link`, `orphan` (ссылка в репо, но исходник удалён).

**Затащить существующий конфиг в репо** — `--adopt` делает `mv ~/x → home/x` и симлинк обратно:

```bash
python install/main.py --adopt ~/.config/kitty        # dry-run, принимает файлы и каталоги
python install/main.py --adopt ~/.config/kitty -f     # применить
python install/main.py --adopt ~/.ssh/config -f -o    # применить, забрав системную версию поверх репо
```

Если файл уже есть в репо с другим содержимым — `--adopt` отказывается и печатает команду `diff`;
`-o` разрешает перезаписать репо-версию системной. Симлинки пропускаются, пути внутри репо отклоняются.

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

**Скрипты** в `home/.config/eww/scripts/` (полная документация в `scripts/README.md`):

| Скрипт | Что делает | Вывод |
|---|---|---|
| `active-window` | Заголовок активного окна с иконкой класса; стримит события через Hyprland socket2 | строка |
| `workspaces` | JSON-массив из 5 воркспейсов (`id`, `active`, `occupied`); стримит события | JSON array |
| `cpu` | Загрузка CPU в % (два чтения /proc/stat с sleep 0.3) | int |
| `cpu-cores` | Загрузка по ядрам + топ-5 процессов по CPU (кэш в /tmp/eww_cpu_cores) | JSON |
| `memory-details` | RAM/cache/swap + топ-5 процессов по памяти из /proc/meminfo | JSON |
| `temperatures` | Все hwmon-сенсоры из /sys/class/hwmon | JSON array |
| `network` | Интерфейс, Wi-Fi сигнал или имя iface, скорость ↓↑ (кэш в /tmp) | строка |
| `volume [up\|down\|mute]` | Чтение/управление дефолтным sink (wpctl); flash-анимация при изменении | строка |
| `audio-sinks` | Список всех PipeWire sinks с флагом active (pactl) | JSON array |
| `audio-sink-select <name>` | Выставить default sink, обновить переменную eww, закрыть popup | — |
| `popup-open <prefix> <pin>` | Открыть popup на активном мониторе + запустить таймер auto-close | — |
| `popup-toggle <prefix> <pin>` | Переключить пин; при unpin — закрыть popup на обоих мониторах | — |
| `popup-hover-out <prefix> <pin>` | Закрыть popup при уходе мыши, если не запинен | — |
| `popup-auto-close <prefix> <pin>` | Фоновый процесс: закрыть через 5s если не запинен | — |

> **При добавлении или изменении скрипта** — обновить эту таблицу И `scripts/README.md`.

**Перезагрузка eww:** `eww reload`

## Zsh config structure

`home/.zshenv` → sets `ZDOTDIR=~/.config/zsh` and sources `~/.config/zsh/.zshenv`.

All zsh config lives in `home/.config/zsh/`:
- `.zshrc` — plugins (Zinit), prompt (p10k), sources all `aliases/*`
- `settings/plugins.zsh` — Zinit plugin declarations
- `settings/bindings.zsh` — key bindings
- `aliases/01_standard_app_replacement.zsh` — modern CLI replacements: `eza`→`ls`, `bat`→`cat`, `duf`→`df`, `rg`→`grep`, `nvim`→`vim`
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
