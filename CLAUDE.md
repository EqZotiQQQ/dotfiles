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

**Единственная точка входа — `./dot`** (тонкий shim над `install/main.py`; вся логика в python).
Ничего не применяется без `-f` — по умолчанию dry-run.

```bash
# Fresh Manjaro install — desktop profile + symlinks:
./dot --profile desktop --symlinks -f

# Fresh Ubuntu install — workstation + build from source + symlinks:
./dot --os ubuntu --profile workstation --open-source --symlinks -f

# Отдельные компоненты вместо профиля (OS определяется автоматически):
./dot --wm --editor
```

OS берётся из `ID=` в `/etc/os-release`, если не задана через `--os`; имя маппится в `install/<os>.sh`.
`--profile` и любые нераспознанные `--флаги` пробрасываются в этот скрипт как есть.

**`install/`** — все скрипты установки:
- `install/main.py` + `install/app_settings.py` — вся логика: пакеты, симлинки, status, adopt
- `install/manjaro.sh` — paru-based; profiles: `minimal`, `desktop`, `full`
- `install/ubuntu.sh` — apt-based; profiles: `minimal`, `workstation`, `full`
- `install/open_source.sh` — builds from source: `--i3lock`, `--rofi`, `--picom`

**Симлинки** — `home/` → `~`, `etc/` → `/etc` (если каталог есть), `wallpapers/` → `~/Pictures/wallpapers`:

```bash
./dot --status  # что разошлось между репо и ~ (exit 1 если есть расхождения)
./dot -s        # dry-run
./dot -s -f     # применить
./dot -s -f -o  # применить + перезаписать существующие
```

`--status` классифицирует каждый файл: `linked`, `missing`, `differs` (реальный файл, содержимое разошлось),
`copy` (реальный файл, содержимое совпадает), `wrong-link`, `broken-link`, `orphan` (ссылка в репо, но исходник удалён).
`--status` смотрит только на `home/` и `etc/`, обои не проверяет.

**Затащить существующий конфиг в репо** — `--adopt` делает `mv ~/x → home/x` и симлинк обратно:

```bash
./dot --adopt ~/.config/kitty        # dry-run, принимает файлы и каталоги
./dot --adopt ~/.config/kitty -f     # применить
./dot --adopt ~/.ssh/config -f -o    # применить, забрав системную версию поверх репо
```

Если файл уже есть в репо с другим содержимым — `--adopt` отказывается и печатает команду `diff`;
`-o` разрешает перезаписать репо-версию системной. Симлинки пропускаются, пути внутри репо отклоняются.

Новые файлы в репо подхватываются рекурсивно — после добавления достаточно `./dot -s -f`.

## Hyprland

Hyprland 0.56 — конфиг на **Lua** (hyprlang `.conf` deprecated с 0.55, удаляется в 0.57).
Вики: https://wiki.hypr.land/0.56.0/Configuring/Start/ ; Lua-стабы для LSP: `/usr/share/hypr/stubs/`.

Конфиги в `home/.config/hypr/`:
- `hyprland.lua` — основной конфиг; keybindings вынесены в `keybindings.lua` (`require("keybindings")`)
- `keybindings.lua` — все бинды клавиш (`hl.bind`); `terminal`/`fileManager`/`menu` — глобалы из `hyprland.lua`
- `theme.lua` — читает общую тему `~/.config/theme/theme.json` (через `lib/json.lua`, rxi/json.lua, MIT);
  из неё в `hyprland.lua` берутся рамки, отступы, скругления, размытие, кривая анимации окон.
  Если тема не читается — эти значения остаются дефолтными Hyprland, остальной конфиг грузится
  (`require` в Hyprland сам сообщает об ошибке и возвращает заглушку, а не бросает исключение)
- `hyprpaper.conf`, `hypridle.conf` — обои / автоблокировка (остаются на hyprlang); `hypridle` → `lock_cmd = ~/.local/bin/lock`
- `hyprlock.conf` — не используется (локскрин теперь Quickshell, см. «Локскрин»)

**Лаунчер — wofi** (`SUPER+R`, повторное нажатие закрывает): полупрозрачный, размытие — `hl.layer_rule` для namespace `wofi`
в hyprland.lua; действия приложений (`.desktop` actions): Right раскрывает, Tab — по действиям. `hyprpaper-set` — выбор
обоев в wofi с превью (миниатюры через `magick`, кэш `~/.cache/hyprpaper-set`).

**Проверка конфига без применения:** `Hyprland --verify-config` (или `-c <path>`).

**`hyprctl dispatch` принимает Lua**, а не старые имена диспатчеров:
`hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`, `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`.

**Автозапуск** (`hl.on("hyprland.start", ...)` в hyprland.lua):
```
hyprpaper, hypridle, qs (Quickshell: бар + spectrum за ним), mako, hyprpolkitagent
```
Плюс приложения из `startup_apps` в hyprland.lua: первое окно каждого класса уходит на свой воркспейс (событие `window.open`).
Не через правила `exec_cmd`: они привязаны к PID, а `code` / `spotify-launcher` открывают окно из другого процесса.
У Hyprland в `PATH` нет `~/.local/bin` — свои скрипты из автозапуска/hypridle вызывать по полному пути.

**spectrum за баром:** слои снизу вверх — hyprpaper → spectrum (`background`, стартует через 1 с после Quickshell, т.е. после
hyprpaper) → бар (`top`, острова висят над полосой). Запускает и перезапускает его Quickshell (`bar/Spectrum.qml`, по процессу
на монитор): край — как у бара (`bar.position`), столбики растут от края, толщина и цвета — `spectrum.size` / `spectrum.colors`;
флаги `--render.window.layer_shell.anchor`, `--render.window.height|width`, `--render.orientation`, `--render.colors.*`.
Запуск через `setpriv --pdeathsig TERM`: spectrum умирает вместе с `qs`; при перезагрузке QML старый процесс гасится явно.

## Тема (`home/.config/theme/theme.json`)

Единый источник внешнего вида: палитра (Material-подобная: `primary`, `onPrimary`, `surface`, `outline`…), формы
(скругления, отступы, размеры бара), размытие, кривая анимаций, шрифты, полоса spectrum, тема локскрина.
Читают: бар и spectrum (Quickshell, сразу: файл отслеживается), Hyprland (`hypr/theme.lua`, при перезагрузке конфига),
`lock` (при блокировке). Ключи — `home/.config/theme/README.md`. Kitty и wofi в тему не входят (Gruvbox в `kitty/theme.conf`, `wofi/style.css`).

## Quickshell (статусбар)

Quickshell 0.3 (QML), конфиг в `home/.config/quickshell/`, запуск `qs`. Перезапуск: `pkill -x qs; qs -d` (`qs kill` экземпляр, запущенный с `-d`, не находит). Логи: `qs log`.
Правки QML подхватываются сами, но замену файла (`sed -i`, новый inode) вотчер по симлинку теряет — тогда перезапуск.
- `shell.qml` — на каждый экран бар (`bar/Bar.qml`) и полоса spectrum (`bar/Spectrum.qml`)
- `common/` — синглтоны `Theme` (theme.json), `Icons` (глифы Nerd Font), `Time` (часы + локаль `LC_TIME`); `ThemeAnim`, `StyledText`,
  `Strip` (ряд на горизонтальном баре / колонка на вертикальном)
- `services/` — данные: `Cpu`, `Memory` (/proc), `Sensors` (hwmon, `scripts/sensors`), `Network`, `Audio` (PipeWire),
  `Keyboard` (раскладка: событие Hyprland `activelayout`), `Mako` (режим «не беспокоить»)
- `bar/Bar.qml` — бар у края `bar.position` из theme.json (`top|bottom|left|right`, переключается на лету), слой `top`,
  namespace `quickshell-bar`, без размытия (виден spectrum); поверхность глубже бара для поповеров, ввод только на островах
  (`mask`); бар прячется на мониторе с полноэкранным окном
- три острова вдоль края: `Workspaces` + `ActiveWindow` (на вертикальном — только иконка), `Dock` (по центру, но не наезжает
  на соседей; закреплённые: `pinned` в `Dock.qml`, плюс запущенные), `StatusIsland` — модули `Chip` и поповеры
  `bar/popouts/*`: наведение открывает, клик закрепляет; панель выезжает от края на уровне модуля, остров и панель —
  одна `Shape` с вогнутыми стыками, геометрия считается в системе «от края / вдоль края» и отображается на нужный край;
  пока поповер открыт, фигура почти непрозрачна (`opacity.popout`)
- воркспейсы: номера 1–9 своего монитора (id 1–9 — DP-2, 10–18 — DP-1, правила в hyprland.lua), пустые не показываются
- `launcher/Launcher.qml` — лаунчер приложений в стиле бара, альтернатива wofi; **не подключён**. Включить: `Launcher {}`
  (+ `import qs.launcher`) в `shell.qml` и `menu = "qs ipc call launcher toggle"` в hyprland.lua

**Подводный камень QML:** свойства с именем `onXxx` (как `onSurface`) читаются как обработчики сигналов и дают
`#000000` — поэтому в `Theme.qml` цвета текста названы `text`, `textVariant`, `textOnPrimary`, `textOnPrimaryContainer`.

## Локскрин

`home/.local/bin/lock` — блокировка Quickshell-локскрином. Движок — qylock (`~/.local/share/qylock`, sparse checkout:
только `quickshell-lockscreen` + выбранные темы), темы в формате SDDM (`Main.qml`, `theme.conf`, PAM через Quickshell).
Тема — `lock.theme` в theme.json: сначала ищется в `home/.config/lockscreen/themes/`, потом в темах qylock.
```bash
lock                    # заблокировать (SUPER+L → loginctl lock-session → hypridle → lock)
lock --preview [тема]   # показать тему в окнах, без блокировки
lock --list             # установленные темы
lock --fetch [тема]     # поставить движок qylock / докачать его тему
lock-theme              # выбрать из всех тем (fzf, ссылки на GIF-превью), скачать и включить
lock-theme list | link <тема> | install <тема>
```
`lock-theme` (python) берёт список тем qylock из дерева sparse-клона (`git ls-tree`, без сети), включает тему заменой
только значения `lock.theme` в theme.json (форматирование файла сохраняется).
Своя тема `pixel-city` (пиксельный ночной город с дождём): `home/.config/lockscreen/themes/pixel-city/`, опции в `theme.conf`.

## eww (не используется)

Заменён Quickshell-баром; конфиги оставлены в репо. Конфиги в `home/.config/eww/`:
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
- `lock` — Quickshell lockscreen (см. «Локскрин»)
- `lock-theme` — выбор / скачивание / включение темы локскрина
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
