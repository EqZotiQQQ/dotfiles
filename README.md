

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

Бару нужен `Hack Nerd Font` (иконки), kitty — `Iosevka Nerd Font`. В apt только обычные Hack/Iosevka:

```bash
mkdir -p ~/.local/share/fonts/nerd && cd ~/.local/share/fonts/nerd
for f in Hack Iosevka; do
  curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.tar.xz"
  tar -xf "$f.tar.xz" && rm "$f.tar.xz"
done
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