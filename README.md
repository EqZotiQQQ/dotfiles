

TODO:
docs

# Requirements
TBD

# Getting started
TBD

# Configuration
TBD

# Ubuntu: Hyprland

Что пришлось доставить поверх `./dot --os ubuntu`, чтобы WM заработал (проверено на Ubuntu 26.04,
Hyprland 0.56.2, RTX 5070 Ti). Всё это делает `./dot --os ubuntu --wm` (входит в `--profile desktop`),
шрифты — `--fonts`; ниже — что и зачем.

## Hyprland

Стек hyprwm (Hyprland, hyprpaper, hypridle, hyprlock, hyprpolkitagent, xdg-desktop-portal-hyprland, uwsm…)
в apt старый — собирается из исходников скриптом [hyprbuntu](https://gitlab.com/kralos/hyprbuntu)
(клон в `~/open_source/hyprbuntu`, сборка в `~/hyprbuntu`), без вопросов: опции заданы в `ubuntu.sh`.

`hyprland` и прочие `hypr*` из apt не ставить: после `apt remove hyprland` остаются `libhypr*` / `libaquamarine*`
в `/usr/lib/x86_64-linux-gnu`, линкер смотрит туда раньше `/usr/lib` (куда ставит hyprbuntu), и Hyprland
грузит старые библиотеки (`ldd $(which Hyprland) | grep hypr`). `--wm` такие пакеты сносит перед сборкой.

## NVIDIA (RTX 50xx)

Blackwell работает только с open-модулем ядра. Если рядом с `nvidia-driver-*-open` стоят пакеты
закрытого модуля, грузится он, и в `journalctl -k` видно
`requires use of the NVIDIA open kernel modules` / `RmInitAdapter failed`, а `nvidia-smi` — `No devices were found`.

```bash
sudo apt purge linux-modules-nvidia-595-generic-hwe-26.04 \
  linux-modules-nvidia-595-$(uname -r) linux-modules-nvidia-595-7.0.0-30-generic
sudo update-initramfs -u && sudo reboot
nvidia-smi   # карта должна быть видна
```

## Пакеты

```bash
sudo apt install wofi wtype imagemagick jq flameshot
```

`hyprpolkitagent` на Ubuntu лежит в `/usr/libexec`, а `hyprland.lua` запускает его по пути из Arch:

```bash
sudo mkdir -p /usr/lib/hyprpolkitagent
sudo ln -s /usr/libexec/hyprpolkitagent /usr/lib/hyprpolkitagent/hyprpolkitagent
```

## Шрифты

Бару нужен `Hack Nerd Font` (иконки), в apt только обычный Hack. kitty хватает обычного Iosevka:
значки Nerd Font встроены в сам kitty.

```bash
mkdir -p ~/.local/share/fonts/nerd && cd ~/.local/share/fonts/nerd
curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz"
tar -xf Hack.tar.xz && rm Hack.tar.xz
fc-cache -f
```

## Quickshell

В apt нет, собирается из исходников. Опция называется `CRASH_HANDLER` (не `CRASH_REPORTER`);
без `OFF` нужен `cpptrace`, которого в Ubuntu нет.

```bash
sudo apt install cmake ninja-build pkg-config spirv-tools libcli11-dev \
  qt6-base-dev qt6-base-private-dev qt6-declarative-dev qt6-declarative-private-dev \
  qt6-wayland-dev qt6-wayland-private-dev qt6-shadertools-dev qt6-svg-dev \
  libwayland-dev wayland-protocols libdrm-dev libgbm-dev libpipewire-0.3-dev \
  libpam0g-dev libjemalloc-dev libpolkit-agent-1-dev libglib2.0-dev libxcb1-dev \
  qml6-module-qtquick qml6-module-qtquick-layouts qml6-module-qtquick-shapes \
  qml6-module-qtquick-effects qml6-module-qtquick-controls qml6-module-qtquick-window \
  qml6-module-qtqml-workerscript qml6-module-qt5compat-graphicaleffects

git clone --branch v0.3.2 https://git.outfoxxed.me/quickshell/quickshell ~/open_source/quickshell
cd ~/open_source/quickshell
cmake -GNinja -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCRASH_HANDLER=OFF
cmake --build build && sudo cmake --install build

lock --fetch   # движок локскрина qylock, нужен qs
```

- `qs` из SSH падает с `could not connect to display` / xcb — это не нехватка `libxcb-cursor0`, а отсутствие
  Wayland-окружения. Запускать внутри сессии: `hyprctl dispatch 'hl.dsp.exec_cmd("qs -d")'`.
- Qt 6.10 не принимает `long` / `short` как имена в QML (`Expected token 'identifier'`).
  Проверка всех файлов: `/usr/lib/qt6/bin/qmllint` (пакет `qt6-declarative-dev-tools`).

### AI Limits: Codex и Claude

Виджет показывает аккаунты двумя группами: `Codex`, затем `Claude`. Все подписи
и сообщения — на английском. В группе Codex отображается имя аккаунта
из `accounts.name` в sub2api. Для Claude используются подписи `ClaudeAccount1…`
по возрастанию ID; после удаления аккаунта их нумерация может измениться.

Для каждого аккаунта:

- `5h used: …%` и `7d used: …%` — **использованный** процент по последнему снимку;
  `Reset in: …` — время до сброса каждого окна.
- `Last invoked: …` — время с `accounts.last_used_at`.
- `Cache miss: …` и `Cache hit: …` — входные токены последнего завершённого запроса
  из `usage_logs`, в одной строке с последним вызовом. `k` и `M` сокращают тысячи
  и миллионы, с округлением до одного знака.
- Cache miss складывается из обычных входных токенов и токенов новой записи в кэш;
  cache hit — токены, прочитанные из кэша. В sub2api эти три категории не пересекаются.
  Пока новый запрос ещё выполняется, значения кэша относятся к предыдущему завершённому запросу.

Внизу `Fetch in: …s` отсчитывает время до следующего опроса; во время запроса
показывается `Fetching...`. Один сервис `services/AiLimits.qml` опрашивает VPS
раз в минуту для всех мониторов. Длительность запроса ограничена 20 секундами,
одновременных запросов нет. Плагин использует готовую поверхность Quickshell
для переднего слоя, отдельного опроса для него нет.

AI Limits находится под фактическим боксом proctree: правые края выровнены,
между внешними границами — `widgetReveal.gap` (по умолчанию 20 px).
Карточка шире прежней, чтобы строка последнего вызова и кэша помещалась целиком.
Цвета, шрифты, подложка и проявление поверх окон описаны ниже.

`scripts/ai-limits` передаёт собственный Python-код через SSH на `ruweb_hosting`
(локальное имя VPS с sub2api). Требуются Python 3 на обеих машинах, SSH без запроса
пароля и доступ пользователя VPS к Docker. Контейнер PostgreSQL — `sub2api-postgres`;
имя пользователя и базы читаются из его `POSTGRES_USER` / `POSTGRES_DB`.

Сборщик выполняет `SELECT` в транзакции `READ ONLY`, с таймаутами SQL и блокировок.
Для OAuth-аккаунтов OpenAI он читает `codex_*` из `accounts.extra`, для Anthropic —
`session_window_utilization`, `passive_usage_7d_utilization`, `passive_usage_7d_reset`,
`passive_usage_sampled_at` и колонку `session_window_end`. Доли Claude 0…1 переводятся
в проценты 0…100. Схема проверена на sub2api 0.2.19; при обновлении нужно проверять
совместимость этих полей. Источники формата:
[снимки квот](https://github.com/Wei-Shaw/sub2api/blob/v0.2.19/backend/internal/service/account_usage_service.go)
и [категории токенов](https://github.com/Wei-Shaw/sub2api/blob/v0.2.19/backend/internal/service/openai_gateway_usage.go).
Токены авторизации и запросы пользователей не читаются. Модель и внешние API квот не вызываются.

- Отсутствующие квоты, сбросы, вызовы и значения кэша показываются как `N/A`,
  а настоящий ноль — как `0`. Без сохранённого снимка Claude его квоты остаются `N/A`.
- Возраст снимка считается по `codex_usage_updated_at` или `passive_usage_sampled_at`.
  Через 5 минут известные квоты помечаются `Stale`.
- После истечения окна остаётся последнее измерение с `Reset in: Awaiting update`;
  нулевое использование не предполагается.
- Ограничение, отключение, пауза, перегрузка или ошибка аккаунта обозначаются
  английским статусом рядом с именем. При ошибке опроса сохраняется предыдущий
  снимок с явным сообщением об ошибке.

Установка и проверка из корня репозитория:

```bash
./dot -s -f
~/.config/quickshell/scripts/ai-limits --host ruweb_hosting
python3 -m unittest discover -s tests -p 'test_ai_limits*.py' -v
```

Тесты используют вымышленные аккаунты и запросы, без доступа к VPS. QML-тест
сервиса проверяет сбои, восстановление, пустые ответы, группировку и обратный отсчёт.
Проверка текста и структуры виджета требует Wayland-сеанса и явно пропускается
без него. После первого добавления файлов перезапустите оболочку в графической
сессии: `pkill -x qs`, затем `qs -d`.

### Виджеты поверх окон у верхнего края

В `home/.config/theme/theme.json` переключите `widgetReveal.mode`:

```json
"widgetReveal": {
  "mode": "delay",
  "delayMs": 450,
  "pressureThreshold": 120,
  "fadeMs": 360,
  "gap": 20,
  "backdrop": {
    "color": "#242424",
    "opacity": 0.65,
    "padding": 16,
    "radius": 18,
    "blur": true,
    "blurOpacity": 0.35
  }
}
```

`delay`: держите курсор у верхнего края монитора 450 мс, затем AI Limits и proctree
плавно появятся поверх окон, включая полноэкранные. `pressure`: продолжайте двигать мышь
вверх после упора; накопленное движение управляет степенью появления. Просто
стоять у края в этом режиме недостаточно. Уход от края плавно возвращает виджет
под окна и сбрасывает жест. Эффект действует только на мониторе под курсором.
Клики проходят насквозь. Перетаскивание с зажатой кнопкой, блокировка сеанса
и захват курсора приложением отключают жест.

Подключены AI Limits и proctree: плагин рисует их готовые Wayland-буферы вместе,
в одном проходе поверх окон, с одинаковым прогрессом появления. Исходные поверхности
остаются прозрачными виджетами рабочего стола, клики и фокус не меняются.
В переднем слое обе подложки используют один цвет, непрозрачность, скругление,
отступы и блюр. Подложка proctree охватывает фактически нарисованные узлы, линии,
подписи с ореолами и панели. AI Limits расположен ниже, правые края боксов совпадают.
`widgetReveal.gap` задаёт зазор между внешними границами. Положение передней копии
AI Limits рассчитывается заново в каждом кадре, поэтому рост proctree и его отступов
не приводит к перекрытию во время анимации. Положение настольной поверхности
обновляется по событиям `widgetbounds`; пока границ proctree нет, AI Limits скрыт.
Цвет, непрозрачность, отступ, радиус, включение и степень проявления блюра задаются
в `widgetReveal.backdrop`. Сила фильтра — общие `blur.size` и `blur.passes` темы
(для них нужен `hyprctl reload`). Подложки плавно появляются и исчезают вместе с содержимым.
Блюр ограничен пересечением бокса виджета и области вне бара: размытие одной
подложки не перерисовывает соседние окна или второй виджет.

Для компактного бокса нужен обновлённый proctree из `~/my_projects/proctree`:
`render.window.layer_shell.visible_bounds: true` в его конфиге включает передачу
границ через `hyprland-surface-v1` v2. Границы обновляются при изменениях дерева,
текста, анимации и размера окна. Старый бинарник не публикует их, и плагин
не рисует для него подложку. При включённом `visible_bounds` несовместимый
композитор выдаёт явную ошибку запуска.
После аварийного завершения Quickshell передние копии виджетов исчезают за 1,5 с.
Используется namespace `proctree` (`render.window.title` в его конфиге).
Бар остаётся над поднятыми виджетами. Их содержимое, подложки и блюр обрезаются по рабочей
области вне зарезервированного места бара, поэтому отступы подложек не заходят под
полупрозрачные плитки приложений и статуса. Ограничение учитывает край бара и масштаб монитора.
spectrum остаётся на рабочем столе.
Все параметры и ограничения — в [описании темы](home/.config/theme/README.md).
Переключение режима применяется сразу, перезапуск нужен только при первой установке файлов.

Оба режима используют `native/widget-edge.cpp`: плагин Hyprland 0.56 получает
положение курсора и относительные движения, не захватывая ввод. Quickshell
автоматически собирает и загружает его через `scripts/widget-edge`.
Нужны C++23-компилятор (`c++`, либо переменная `CXX`), `pkg-config`, заголовки Lua и
Hyprland с зависимостями, соответствующие запущенному композитору.
В Manjaro это `base-devel`, `pkgconf` и установленный `hyprland`; на Ubuntu
используется установка Hyprland из исходников выше. Проверка доступности заголовков:
`pkg-config --cflags hyprland lua`.

Библиотека хранится в `~/.cache/quickshell/widget-edge` (или `$XDG_CACHE_HOME`),
пересобирается при изменении исходника, компилятора или версии заголовков.
После обновления Hyprland сначала перезапустите графический сеанс: плагин
отклоняет несовместимую версию. Ошибка сборки, загрузки или настроек показывается
уведомлением и в `qs log`; подмены режима давления задержкой нет.

Установка из корня репозитория, внутри графической сессии:

```bash
./dot -s -f
make -C ~/my_projects/proctree release
~/.config/quickshell/scripts/widget-edge --build  # только сборка, без загрузки
pkill -x proctree
hyprctl dispatch 'hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/proctree")'
pkill -x qs
qs -d
```

Проверки:

```bash
python3 -m unittest discover -s tests -p 'test_widget_reveal.py' -v
ctest --test-dir ~/my_projects/proctree/build --output-on-failure
hyprctl plugin list -j  # widget-edge после запуска Quickshell
qs log
```

Проверка обрезки компилирует функции отрисовки плагина с тестовым приёмником команд;
нужны `c++`, `pkg-config` и заголовки Hyprutils. Она проверяет все четыре края бара,
масштабы 1…2, отсутствие бара и полностью занятую панелями область.

Тесты проверяют задержку, отмену, накопление давления, смену монитора/режима,
плавное скрытие и передачу одного прогресса для обоих виджетов. Проверка положения AI Limits
требует Wayland-сеанса, проверка команды плагина — Hyprland с загруженным
`widget-edge`; без них соответствующий тест явно пропускается. VPS не опрашивается.
Тесты proctree проверяют компактные границы, текстовые ореолы, панели и обрезку
по видимой области буфера; тест Quickshell проверяет общий стиль, параметры подложки,
выравнивание и зазор при росте proctree, а также восстановление после некорректного конфига.
Вручную проверьте оба режима у верхнего края,
уход мыши вниз и переключение между мониторами. В режиме `pressure` неподвижный
курсор не должен проявлять виджет, а дополнительное движение вверх должно.

## proctree

```bash
sudo apt install libsdl3-dev libyaml-cpp-dev libboost-program-options-dev libgtest-dev
cd ~/my_projects/proctree && make release
ln -s ~/my_projects/proctree/build/proctree ~/.local/bin/proctree   # отсюда его запускает hyprland.lua
```

## spectrum

Quickshell ищет бинарник в `~/my_projects/spectrum/build/spectrum`; без него — только уведомление при старте.

## Необязательно

- `dolphin` (`fileManager` в hyprland.lua) — на Ubuntu есть только nautilus; ставит `--apps`.
- Приложения из `startup_apps`: `code` (`--editor`), `google-chrome-stable`, `telegram-desktop` (`--apps`);
  `obsidian`, `spotify-launcher` — нет.

# TODO
transparent and blur for term
Setup startup screens

## Codex: правила и скиллы

Пользовательские настройки Codex хранятся рядом с настройками Claude:

- `home/.codex/AGENTS.md` → `~/.codex/AGENTS.md`: постоянные правила работы
  с кодом и документацией. Проектные уточнения размещаются в `AGENTS.md`
  соответствующего репозитория.
- `home/.agents/skills/` → `~/.agents/skills/`: пользовательские скиллы Codex.
  Скиллы конкретного проекта размещаются в его `.agents/skills/`.

| Вызов | Для чего |
| --- | --- |
| `$karpathy-guidelines` | Простой код, точечные изменения и проверяемый результат |
| `$systematic-debugging` | Воспроизведение, поиск причины и проверка исправления |
| `$documentation` | README, API-документация, архитектура, runbook, onboarding |
| `$improve` | Аудит и самостоятельные планы реализации в `plans/` |
| `$grill-me` | Последовательное интервью для проработки плана или решения |
| `$find-skills` | Поиск и установка подходящих скиллов |

`grill-me` вызывается явно; остальные скиллы Codex может выбирать по задаче.
Например: `$improve plan добавить экспорт CSV` или
`$documentation обнови README под текущий CLI`.

Для новой установки используйте `./dot -s` для просмотра и `./dot -s -f`
для создания ссылок. Существующие файлы без `-o` не заменяются: если
`~/.codex/AGENTS.md` уже содержит правила, сначала объедините их вручную.
Новые глобальные инструкции загрузятся при следующем запуске сессии Codex.
Изменения скиллов обнаруживаются автоматически; если скилл не появился,
перезапустите Codex.

Перенесены пользовательские скиллы Claude и техническая документация из
engineering-плагина. Зависимости от Claude Skill tool, `superpowers` и имён
моделей Claude заменены самостоятельными инструкциями. Настройки моделей,
учётные данные и MCP-коннекторы не переносятся.
Облачные документы Claude требуют своего коннектора; скилл `documentation`
отвечает за документацию проекта и не заменяет облачный редактор.

Формат и размещение сверены с официальной документацией OpenAI:
[AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) и
[скиллы](https://learn.chatgpt.com/docs/build-skills).

### История и выжимки сессий Codex

`home/.codex/hooks.json` подключает `SessionEnd`-хук
`home/.codex/hooks/session-summary` и `home/.codex/hooks/session-history`.
История сохраняется локально в
`~/codex-conversations-history/<проект>/<session_id>.jsonl` как полная копия
транскрипта Codex: реплики, вызовы инструментов с командами и их результаты.
Формат JSONL сохраняет также служебные записи; файл может содержать приватные
данные из диалога и вывода команд. Ошибки записи пишутся в
`~/.cache/codex-session-history.log`.

После установки ссылок (`./dot -s -f`)
перезапустите Codex и откройте `/hooks` в CLI, чтобы проверить и доверить новый
хук. Существующий `~/.codex/hooks.json` установщик без `-o` не заменяет —
если он уже есть, объедините настройки вручную.

Хук запускает фоновый процесс, который читает транскрипт и создаёт русское
Markdown-описание алгоритма действий через `codex exec` с текущими
пользовательскими настройками модели. Claude для этого не нужен. Требуются
авторизованный Codex CLI, Python 3.11+, `rsync` и SSH-доступ к `beelink`.

Описание начинается с «Для <цель> мы сделали: <краткие шаги>», затем идут
пронумерованные действия с пояснениями и разделы «Нюансы», «Ограничения»,
«Плюсы», «Минусы». Хук опирается на содержимое транскрипта; при отсутствии
данных для раздела пишет «Не выявлены».

- Файлы: `~/Documents/codex-sessions/<проект>/<начало>_<id>.md`.
  Переменная `CODEX_SESSION_SUMMARY_DIR` меняет корневой каталог.
- В заголовке сохраняются ID, каталог проекта, время начала и окончания,
  причина завершения и команда `codex resume`.
- В транскрипт для выжимки входят реплики и краткие вызовы инструментов;
  служебный контекст, рассуждения и вывод инструментов исключаются.
  Пустые сессии пропускаются, длинные обрезаются посередине.
- Каталог отправляется на `beelink:codex-sessions/`. Если сервер недоступен,
  локальная выжимка сохраняется; следующая синхронизация повторит отправку.
- Лог: `~/.cache/codex-session-summary.log`. Вложенный запуск не сохраняет
  свою сессию и отключает хуки; дополнительно от рекурсии защищает
  `CODEX_SESSION_SUMMARY=1`.

Как описано в [документации OpenAI о хуках](https://learn.chatgpt.com/docs/hooks),
`SessionEnd` запускается при штатном закрытии Codex, архивировании/удалении
открытого диалога либо через 30 минут простоя диалога без подключённых клиентов.
Переключение вкладки само по себе не завершает сессию.
