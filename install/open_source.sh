#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Builds and installs tools from source / git.
# Clones into ~/open_source/<name>; skips if already cloned.
#
# Components
#   --i3lock   i3lock-color + multilockscreen  (X11, Ubuntu deps via apt)
#   --rofi     rofi + rofi-themes-collection   (Ubuntu deps via apt)
#   --picom    picom compositor                (X11/Ubuntu, not needed on Hyprland)
#
# Profiles
#   --all      everything
# ---------------------------------------------------------------------------

OPEN_SOURCE_DIR="${HOME}/open_source"
mkdir -p "${OPEN_SOURCE_DIR}"

DO_I3LOCK=false
DO_ROFI=false
DO_PICOM=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Component flags:
  --i3lock    i3lock-color + multilockscreen (X11 lock screen)
  --rofi      rofi launcher + themes collection
  --picom     picom compositor (X11 only, not needed on Hyprland)

Profiles:
  --all       everything

  -h, --help  Show this help
EOF
    exit 0
}

[[ $# -eq 0 ]] && usage

for arg in "$@"; do
    case "$arg" in
        --i3lock)  DO_I3LOCK=true ;;
        --rofi)    DO_ROFI=true ;;
        --picom)   DO_PICOM=true ;;
        --all)     DO_I3LOCK=true; DO_ROFI=true; DO_PICOM=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------

clone_or_skip() {
    local url="$1" dest="$2"
    if [[ -d "$dest" ]]; then
        echo "==> already cloned: $dest, skipping"
    else
        git clone "$url" "$dest"
    fi
}

install_i3lock() {
    echo "==> [i3lock] dependencies"
    sudo apt install -y \
        i3lock \
        imagemagick \
        autoconf \
        pkg-config \
        libpam0g-dev \
        libcairo2-dev \
        libfontconfig1-dev \
        libxcb-composite0-dev \
        libev-dev \
        libx11-xcb-dev \
        libxcb-xkb-dev \
        libxcb-xinerama0-dev \
        libxcb-randr0-dev \
        libxcb-image0-dev \
        libxcb-util-dev \
        libxcb-xrm-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libjpeg-dev

    local i3lock_dir="${OPEN_SOURCE_DIR}/i3lock-color"
    clone_or_skip https://github.com/Raymo111/i3lock-color.git "$i3lock_dir"
    (
        cd "$i3lock_dir"
        ./build.sh
        ./install-i3lock-color.sh
    )

    local multilock_dir="${OPEN_SOURCE_DIR}/multilockscreen"
    clone_or_skip https://github.com/jeffmhubbard/multilockscreen "$multilock_dir"
    sudo install -Dm 755 "$multilock_dir/multilockscreen" /usr/bin/multilockscreen
}

install_rofi() {
    echo "==> [rofi] install + themes"
    sudo apt install -y rofi

    local themes_dir="${OPEN_SOURCE_DIR}/rofi-themes-collection"
    clone_or_skip https://github.com/lr-tech/rofi-themes-collection.git "$themes_dir"

    local dst="${HOME}/.local/share/rofi/themes"
    mkdir -p "$dst"
    cp -r "$themes_dir/themes/." "$dst/"

    echo "==> [rofi] run 'rofi-theme-selector' to pick a theme (Alt+a to apply)"
}

install_picom() {
    echo "==> [picom] dependencies"
    sudo apt install -y \
        libxcb-render-util0-dev \
        libxcb-damage0-dev \
        libxcb-sync-dev \
        libxcb-present-dev \
        libxcb-glx0-dev \
        uthash-dev \
        libconfig-dev \
        libgl-dev \
        libegl-dev \
        libdbus-1-dev

    local picom_dir="${OPEN_SOURCE_DIR}/picom"
    clone_or_skip https://github.com/yshui/picom.git "$picom_dir"
    (
        cd "$picom_dir"
        git submodule update --init --recursive
        meson --buildtype=release . build
        ninja -C build
        sudo ninja -C build install
    )
}

# ---------------------------------------------------------------------------

$DO_I3LOCK && install_i3lock
$DO_ROFI   && install_rofi
$DO_PICOM  && install_picom

echo "==> Done."
