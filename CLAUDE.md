# CLAUDE.md

## Как работать

- Сначала подумать: называть допущения; если неясно или трактовок несколько — спросить, а не выбирать молча.
- Минимум кода: ничего сверх запрошенного, без абстракций и «гибкости» на будущее.
- Хирургические правки: не трогать соседний код и стиль; чужой мёртвый код — упомянуть, не удалять; убирать только то,
  что осиротила своя правка.
- Проверяемая цель: до работы — критерий успеха (воспроизвести → исправить → проверить), для многошаговых задач —
  короткий план с проверкой каждого шага.

## Обзор

Личные dotfiles: Manjaro (и Ubuntu), Hyprland, Zsh (Zinit + p10k), Neovim (AstroNvim).
`home/` симлинкуется в `~`, `wallpapers/` — в `~/Pictures/wallpapers`.

## `./dot` — единственная точка входа

Shim над `install/main.py` (логика — там и в `install/app_settings.py`; пакеты — `install/<os>.sh`, OS из
`/etc/os-release` или `--os`). **Без `-f` всё — dry-run.** От root не запускается: ссылки в `~` стали бы root-овыми.

```bash
./dot --profile desktop --symlinks -f   # новая установка (Ubuntu: --os ubuntu --profile workstation)
./dot --status                          # расхождения репо и ~ (exit 1, если есть)
./dot -s -f [-o]                        # симлинки; -o — перезаписать существующие
./dot --adopt ~/.config/x -f [-o]       # перенести конфиг в репо и симлинкнуть обратно
```

- Новый файл в `home/` появится в `~` только после `./dot -s -f`.
- `etc/` ставится в `/etc` **копиями** (`sudo install`), не ссылками: ссылка дала бы пользователю править конфиг root
  (udev умеет `RUN+=`), а `/home` монтируется позже старта udev.
- Ubuntu: `install/ubuntu.sh --wm` собирает Hyprland и Quickshell из исходников — README, «Ubuntu: Hyprland».

## Hyprland 0.56 (`home/.config/hypr/`)

- Конфиг на **Lua** (hyprlang удаляется в 0.57; на нём остались только `hyprpaper.conf`, `hypridle.conf`).
  Вики: https://wiki.hypr.land/0.56.0/Configuring/Start/ , стабы: `/usr/share/hypr/stubs/`.
- Проверка без применения: `Hyprland --verify-config`.
- `hyprctl dispatch` принимает Lua: `hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`.
- В `PATH` Hyprland нет `~/.local/bin` — свои скрипты из автозапуска и hypridle вызывать по полному пути.
- `startup_apps` ловят первое окно по классу (`window.open`), а не правилами `exec_cmd`: те привязаны к PID, а `code` /
  `spotify-launcher` открывают окно из другого процесса.
- `monitors.lua`: имена выходов не прописаны; главный монитор — самый большой, дальше слева направо; у n-го монитора
  воркспейсы 9(n−1)+1…9n (`SUPER+1..9` — свои 1–9). Это же нумерация в баре и обзоре.
- `layouts.lua`: лейаут у каждого воркспейса свой; выбор — в `$XDG_RUNTIME_DIR/hypr-layouts.json` (его читает и бар).
- Клик мимо wofi закрывает его биндом на `mouse:272/273`: `close_on_focus_loss` не срабатывает.

## Тема — `home/.config/theme/theme.json`

Единый источник внешнего вида, ключи — `theme/README.md`. Читают: Quickshell (сразу), Hyprland (`hypr/theme.lua`, при
перезагрузке конфига), `lock`, mako (через `mako-theme` → `~/.cache/mako-theme`; без этого файла mako не стартует).
Kitty и wofi в тему не входят. Остальным программам шрифты отдаёт fontconfig: `sans-serif` → Rubik, `monospace` → Iosevka.

## Quickshell (`home/.config/quickshell/`)

- Перезапуск: `pkill -x qs; qs -d` (`qs kill` не находит экземпляр с `-d`). Логи: `qs log`.
- Правки QML подхватываются сами, но замену файла целиком (`sed -i`, новый inode) вотчер теряет — тогда перезапуск.
- Новый файл `qs` не видит, пока нет симлинка (`./dot -s -f`); `import` нового каталога до этого роняет весь конфиг.
- JS в QML не знает `??=` — ошибка разбора всего файла.
- Свойства с именем `onXxx` читаются как обработчики сигналов (цвет становится `#000000`) — поэтому в `Theme.qml`
  `text`, `textVariant`, `textOnPrimary`…
- `Quickshell.Networking` экспортирует тип `Network`: в файле с `import qs.services` он молча перекрывает синглтон —
  перечисления Wi-Fi используются только в `services/Network.qml`.
- `DesktopEntries.heuristicLookup("")` отдаёт случайное приложение.
- spectrum (полоса за баром) и proctree — отдельные проекты в `~/my_projects`. spectrum запускает `bar/Spectrum.qml`,
  по процессу на монитор, в слое `background` через 1 с после `qs`: внутри слоя порядок — по запуску, так он над hyprpaper.
- `scripts/wireless`: доступ к hidraw — `etc/udev/rules.d/70-wireless-hid.rules`; каждый запуск держит `flock` на
  устройстве: ответы HID++ / Razer не говорят, на чей они запрос.

## Локскрин

`home/.local/bin/lock` — Quickshell-локскрин на движке qylock (`~/.local/share/qylock`), тема — `lock.theme` в theme.json,
выбор — `lock-theme`. `lock --fetch` накладывает `home/.config/lockscreen/qylock-shim.patch`: без него Enter на пустом
пароле вешает PAM, и локскрин перестаёт принимать ввод.

## Claude Code

`home/.claude/settings.json` общий для профилей `~/.claude-eqzotiqqq` и `~/.claude-panda`. Хук `SessionEnd`
(`home/.claude/hooks/session-summary`) пишет выжимку сессии и отправляет её rsync-ом на `beelink`; от рекурсии —
`CLAUDE_SESSION_SUMMARY=1`, лог — `~/.cache/claude-session-summary.log`.
