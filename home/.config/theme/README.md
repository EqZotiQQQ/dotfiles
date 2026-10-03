# theme.json — общая тема

Один файл задаёт внешний вид всего рабочего стола. Его читают:

| Кто | Как | Когда применяется |
|---|---|---|
| Бар (Quickshell) | `~/.config/quickshell/common/Theme.qml` | сразу, файл отслеживается |
| Hyprland | `~/.config/hypr/theme.lua` (JSON через `hypr/lib/json.lua`) | при перезагрузке конфига: `hyprctl reload` или сохранение `hyprland.lua` |
| spectrum | аргументы из автозапуска в `hyprland.lua` | при следующем входе в сессию |
| Локскрин | `~/.local/bin/lock` берёт `lock.theme` | при следующей блокировке |

Kitty в тему не входит (остаётся на своей Gruvbox: `kitty/theme.conf`).

## Ключи

- `colors` — палитра в духе Material You. `on*` — цвет текста/иконок поверх соответствующей заливки.
  - `primary` — акцент: активный воркспейс, рамка активного окна, индикаторы, шкалы.
  - `primaryContainer` / `onPrimaryContainer` — фон и текст выбранного/открытого (модуль с открытым поповером).
  - `secondary`, `tertiary` — второстепенные акценты (шкалы, выходные в календаре, «не беспокоить»).
  - `surface` — фон островов бара; `surfaceHigh` — плитки дока, дорожки шкал.
  - `onSurface`, `onSurfaceVariant` — основной и приглушённый текст.
  - `outline`, `outlineVariant` — разделители, рамки неактивных окон.
  - `error` — ошибки, перегрев.
- `opacity.panel` — непрозрачность островов бара (за ними размытие Hyprland).
- `shape` — `rounding`, `border`, `gapsIn`, `gapsOut` для окон Hyprland; `barHeight`, `barMargin`,
  `islandRadius`, `tileRadius`, `chipRadius` для бара.
- `blur` — размытие Hyprland (`size`, `passes`).
- `motion` — `curve`: кривая Безье `[x1, y1, x2, y2]` для окон Hyprland и анимаций бара
  (y > 1 даёт лёгкий «перелёт»); `durationMs` — длительность анимаций бара; `hyprSpeed` — скорость
  анимации окон Hyprland; `windowPopin` — с какого масштаба окно «выпрыгивает».
- `fonts` — `ui` (бар), `mono` (числа в баре), `icons` (Nerd Font с иконками), `size`.
- `spectrum` — `height`: высота полосы spectrum за баром, px; `colors`: цвета полос от тихих к громким,
  имена из `colors` или `"#rrggbb"`.
- `lock.theme` — тема локскрина: имя каталога в `~/.config/lockscreen/themes/` или тема qylock
  (`lock --list` — установленные, `lock --fetch <имя>` — скачать, `lock --preview [имя]` — посмотреть).
