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

Configs live in `home/`, symlinked into `~`.

## Setup

**Единственная точка входа — `./dot`** (тонкий shim над `install/main.py`; вся логика в python).
Ничего не применяется без `-f` — по умолчанию dry-run.

```bash
# Fresh Manjaro install — desktop profile + symlinks:
./dot --profile desktop --symlinks -f

# Fresh Ubuntu install — workstation + symlinks:
./dot --os ubuntu --profile workstation --symlinks -f

# Отдельные компоненты вместо профиля (OS определяется автоматически):
./dot --wm --editor
```

OS берётся из `ID=` в `/etc/os-release`, если не задана через `--os`; имя маппится в `install/<os>.sh`.
`--profile` и любые нераспознанные `--флаги` пробрасываются в этот скрипт как есть.

**`install/`** — все скрипты установки:
- `install/main.py` + `install/app_settings.py` — вся логика: пакеты, симлинки, status, adopt
- `install/manjaro.sh` — paru-based; profiles: `minimal`, `desktop`, `full`
- `install/ubuntu.sh` — apt-based; profiles: `minimal`, `workstation`, `full`

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
- `monitors.lua` — мониторы берутся у Hyprland на лету (`hl.get_monitors()`), имена выходов нигде не прописаны.
  Порядок: самый большой — главный, дальше слева направо; n-му монитору принадлежат id 9(n−1)+1…9n
  (`SUPER+1..9` — i-й воркспейс монитора с фокусом). Правила воркспейсов строятся при загрузке конфига;
  при подключении/отключении монитора (`monitor.added|removed`) конфиг перезагружается сам (`hyprctl reload`).
  После перезагрузки (`config.reloaded`) существующие воркспейсы приводятся к раскладке: воркспейс из диапазона
  другого монитора уезжает к нему, а id сверх последнего монитора (остался от отключённого) переносит окна на тот же
  номер 1–9 монитора, где он сейчас, — у каждого монитора только свои 1–9. Заглушка Hyprland `FALLBACK` (пока нет
  ни одного монитора: HDMI-монитор на Ubuntu-машине пропадает, когда засыпает) монитором не считается.
  Общее правило `output = ""` — preferred/auto; правила DP-1/DP-2 — раскладка домашнего стола
- `theme.lua` — читает общую тему `~/.config/theme/theme.json` (через `lib/json.lua`, rxi/json.lua, MIT);
  из неё в `hyprland.lua` берутся рамки, отступы, скругления, размытие, кривая анимации окон.
  Если тема не читается — эти значения остаются дефолтными Hyprland, остальной конфиг грузится
  (`require` в Hyprland сам сообщает об ошибке и возвращает заглушку, а не бросает исключение)
- `hyprpaper.conf`, `hypridle.conf` — обои / автоблокировка (остаются на hyprlang); `hypridle` → `lock_cmd = ~/.local/bin/lock`

**Лаунчер** на `SUPER+R` — wofi (`menu` в hyprland.lua): полупрозрачный, размытие — `hl.layer_rule` для namespace `wofi`;
действия приложений (`.desktop` actions): Right раскрывает, Tab — по действиям. Клик мимо закрывает wofi — это бинд
на `mouse:272/273` в keybindings.lua (`close_on_focus_loss` не срабатывает: эксклюзивный layer-фокус по клику не уходит). `hyprpaper-set` — выбор
обоев в wofi с превью (миниатюры через `magick`, кэш `~/.cache/hyprpaper-set`).

**Проверка конфига без применения:** `Hyprland --verify-config` (или `-c <path>`).

**`hyprctl dispatch` принимает Lua**, а не старые имена диспатчеров:
`hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`, `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`.

**Автозапуск** (`hl.on("hyprland.start", ...)` в hyprland.lua):
```
hyprpaper, hypridle, qs (Quickshell: бар + spectrum за ним + обзор воркспейсов), mako-theme + mako, hyprpolkitagent
```
Плюс приложения из `startup_apps` в hyprland.lua: первое окно каждого класса уходит на свой воркспейс (`workspace` 1–9 на мониторе `monitor` по порядку из monitors.lua; событие `window.open`).
Не через правила `exec_cmd`: они привязаны к PID, а `code` / `spotify-launcher` открывают окно из другого процесса.
У Hyprland в `PATH` нет `~/.local/bin` — свои скрипты из автозапуска/hypridle вызывать по полному пути.

**spectrum за баром:** слои снизу вверх — hyprpaper → spectrum (`background`, стартует через 1 с после Quickshell, т.е. после
hyprpaper) → бар (`top`, острова висят над полосой). Запускает и перезапускает его Quickshell (`bar/Spectrum.qml`, по процессу
на монитор): край — как у бара (`bar.position`), столбики растут от края, толщина и цвета — `spectrum.size` / `spectrum.colors`;
флаги `--render.window.layer_shell.anchor`, `--render.window.height|width`, `--render.orientation`, `--render.colors.*`.
Запуск через `setpriv --pdeathsig TERM`: spectrum умирает вместе с `qs`; при перезагрузке QML старый процесс гасится явно.
Нет бинарника (`~/my_projects/spectrum/build/spectrum`, у proctree — `~/.local/bin/proctree`) — `hyprctl notify` и запуск пропускается.

## Тема (`home/.config/theme/theme.json`)

Единый источник внешнего вида: палитра (Material-подобная: `primary`, `onPrimary`, `surface`, `outline`…), формы
(скругления, отступы, размеры бара), размытие, кривая анимаций, шрифты, полоса spectrum, тема локскрина.
Читают: бар и spectrum (Quickshell, сразу: файл отслеживается), Hyprland (`hypr/theme.lua`, при перезагрузке конфига),
`lock` (при блокировке), mako (`mako-theme` → `~/.cache/mako-theme`, `include` в `mako/config`; при входе и сразу —
его перезапускает Quickshell; без этого файла mako не стартует). Ключи — `home/.config/theme/README.md`. Kitty и wofi в тему не входят (Gruvbox в `kitty/theme.conf`, `wofi/style.css`).

## Quickshell (статусбар)

Quickshell 0.3 (QML), конфиг в `home/.config/quickshell/`, запуск `qs`. Перезапуск: `pkill -x qs; qs -d` (`qs kill` экземпляр, запущенный с `-d`, не находит). Логи: `qs log`.
Правки QML подхватываются сами, но замену файла (`sed -i`, новый inode) вотчер по симлинку теряет — тогда перезапуск.
Новый файл в репо `qs` не видит, пока нет симлинка (`./dot -s -f`): `import` нового каталога до этого роняет весь конфиг.
JS в QML не знает `??=` (ошибка разбора всего файла) — `x = x ?? …`.
- `shell.qml` — на каждый экран бар (`bar/Bar.qml`) и полоса spectrum (`bar/Spectrum.qml`); тема иконок —
  `//@ pragma IconTheme` (как в qt6ct: `qs` его не читает и без прагмы видит только hicolor), читается при старте — перезапуск
- `common/` — синглтоны `Theme` (theme.json), `Icons` (глифы Nerd Font), `Time` (часы + локаль `LC_TIME`); `ThemeAnim`, `StyledText`,
  `Strip` (ряд на горизонтальном баре / колонка на вертикальном)
- `services/` — данные: `Cpu`, `Memory` (/proc), `Sensors` (hwmon, `scripts/sensors`), `Network` (скорость — /proc;
  устройства и Wi-Fi — NetworkManager через `Quickshell.Networking`), `Audio` (PipeWire),
  `Keyboard` (раскладка: событие Hyprland `activelayout`), `Mako` (mako: «не беспокоить», уведомления и история;
  перечитывается по сигналу D-Bus `PropertiesChanged` через `dbus-monitor`, без опроса), `Media` (плееры MPRIS)
- `bar/Bar.qml` — бар у края `bar.position` из theme.json (`top|bottom|left|right`, переключается на лету), слой `top`,
  namespace `quickshell-bar`, без размытия (виден spectrum); поверхность глубже бара для поповеров, ввод только на островах
  (`mask`); бар прячется на мониторе с полноэкранным окном
- три острова вдоль края: `Workspaces` + `ActiveWindow` (на вертикальном — только иконка), `Dock` (по центру, но не наезжает
  на соседей; закреплённые: `pinned` в `Dock.qml`, плюс запущенные), `StatusIsland` — модули `Chip` и поповеры
  `bar/popouts/*`: наведение открывает, клик закрепляет; панель выезжает от края на уровне модуля, остров и панель —
  одна `Shape` с вогнутыми стыками, геометрия считается в системе «от края / вдоль края» и отображается на нужный край;
  пока поповер открыт, фигура почти непрозрачна (`opacity.popout`)
- колокольчик — центр уведомлений mako (`popouts/NotificationsPopout.qml`: живые + история, «вернуть последнее»,
  «не беспокоить»), средний клик — «не беспокоить», число — новые с прошлого открытия; mako возвращает из истории
  только последнее (`makoctl restore`), очистки истории у него нет
- сеть — `popouts/NetworkPopout.qml`: проводные устройства, Wi-Fi вкл/выкл, сети рядом (сканирование — пока поповер
  открыт), клик подключает / отключает; пароль новой WPA-сети вводится в поповере: на это время бар берёт клавиатуру
  (`keyboardFocus: Exclusive`) и поповер закрепляется, Esc — отмена
- медиаплеер — чип с названием трека (только пока есть MPRIS-плеер), средний клик — пауза; `popouts/MediaPopout.qml`:
  обложка, прогресс (клик / перетаскивание — перемотка; у стримов длины нет — полосы нет), shuffle / назад / пауза /
  вперёд / повтор, вкладки плееров, если их несколько. Показывается выбранный во вкладках, иначе последний начавший
  играть; `playerctld` пропускается (он лишь зеркалит остальных). Позицию MPRIS сам не шлёт — пока поповер открыт,
  её раз в секунду перечитывает таймер (`positionChanged()`)
- трей — значки `Quickshell.Services.SystemTray` в начале острова, за разделителем; `org.kde.StatusNotifierWatcher` держит
  сам `qs`, после его перезапуска приложения регистрируются заново. Наведение — меню приложения (`popouts/TrayMenu.qml`:
  D-Bus-меню через `QsMenuOpener`, подменю открываются на месте), клик — к окну приложения (`activateTray`), правый —
  закрепить меню, средний — второе действие, колесо — приложению. Окно, чей класс совпадает с `id`/`title` значка
  (Spotify), фокусируется сразу; иначе — `Activate` приложению (Telegram показывает / прячет окно). Поднять окно
  приложение может только запросом активации, а Hyprland (`focus_on_activate` выкл.) лишь помечает окно urgent —
  его фокусирует `raiseUrgent`, как у календаря; так же после пункта меню («Open Telegram»). `DesktopEntries.heuristicLookup`
  для сопоставления не годится: на пустую строку отдаёт случайное приложение
- воркспейсы: номера 1–9 своего монитора (id 1–9 — главный монитор, 10–18 — второй…, см. `hypr/monitors.lua`), пустые не показываются
- `overview/Overview.qml` — обзор воркспейсов (`SUPER+Tab`: `qs ipc call overview toggle`): на каждом мониторе сетка его
  воркспейсов, включая пустые (по `hyprctl workspacerules -j`), с живыми превью окон (`ScreencopyView` по `toplevel.wayland`;
  окна скрытых воркспейсов тоже захватываются). Захват идёт, только пока обзор открыт; геометрия окон — `lastIpcObject`
  после `Hyprland.refreshToplevels()` при открытии. Клик по окну — фокус на нём, по воркспейсу — переход; Esc / клик мимо — закрыть

**Подводный камень QML:** свойства с именем `onXxx` (как `onSurface`) читаются как обработчики сигналов и дают
`#000000` — поэтому в `Theme.qml` цвета текста названы `text`, `textVariant`, `textOnPrimary`, `textOnPrimaryContainer`.
`Quickshell.Networking` экспортирует тип `Network`: в файле, где есть и `import qs.services`, он молча перекрывает
синглтон (`Network.x` → `undefined`) — поэтому перечисления Wi-Fi (`WifiSecurityType` и т.п.) используются только в `services/Network.qml`.

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
`lock --fetch` накладывает на клон `home/.config/lockscreen/qylock-shim.patch`: без него Enter на пустом пароле вешает
PAM-разговор шима, и локскрин больше не принимает ввод. Перед блокировкой `lock` включает первую раскладку (us).

## Zsh config structure

`home/.zshenv` → sets `ZDOTDIR=~/.config/zsh` and sources `~/.config/zsh/.zshenv`.

All zsh config lives in `home/.config/zsh/`:
- `.zshrc` — plugins (Zinit), prompt (p10k), sources all `aliases/*`
- `settings/plugins.zsh` — Zinit plugin declarations
- `settings/bindings.zsh` — key bindings
- `aliases/01_standard_app_replacement.zsh` — modern CLI replacements: `bat`→`cat`, `duf`→`df`, `rg`→`grep`, `nvim`→`vim`
- `aliases/02_fs_navigation.zsh` — directory stack, `eza`→`ls` (`l`, `ll`, `la`)
- `aliases/03_git.zsh` — git shortcuts (`gs`, `gaa`, `gps`, `gpl`, `gd`, `gl`, `gc`, `gcm`, etc.)

## Scripts

`home/.local/bin/` — shell scripts used by the WM and keybindings:
- `lock` — Quickshell lockscreen (см. «Локскрин»)
- `lock-theme` — выбор / скачивание / включение темы локскрина
- `mako-dnd` — toggle do-not-disturb mode (mako)
- `mako-theme` — цвета mako из theme.json (см. «Тема»)
- `mako-history` — показать историю уведомлений
- `mount_disk.sh` — mounts Windows disk (iCloud/Obsidian access)
- `hypr-reload` — перезагрузить Hyprland конфиг
