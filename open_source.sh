
OPEN_SOURCE_DIR="${HOME}/open_source"
mkdir -p "${OPEN_SOURCE_DIR}"

alias_tips() {
    git clone https://github.com/djui/alias-tips.git "${OPEN_SOURCE_DIR}/alias-tips"
}

picom() {
    picom_path="${OPEN_SOURCE_DIR}/picom"
    git clone https://github.com/yshui/picom.git $picom_path
    cd $picom_path
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
}

i3lock() {
    sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev

    i3lock_color_path="${OPEN_SOURCE_DIR}/i3lock-color"
    # Previously we installed i3lock, which provides beauty lock screen
    git clone https://github.com/Raymo111/i3lock-color.git $i3lock_color_path
    cd $i3lock_color_path
    ./build.sh
    ./install-i3lock-color.sh

    multiscreen_path="${OPEN_SOURCE_DIR}/multilockscreen"
    # Fix and config for i3lock-color https://github.com/noctuid/multilockscreen
    git clone https://github.com/jeffmhubbard/multilockscreen $multiscreen_path
    cd $multiscreen_path
    sudo install -Dm 755 multilockscreen /usr/bin/multilockscreen

    multilockscreen -u ${HOME}/Pictures/witcher.png
}

rofi() {
    rofi_theme="${OPEN_SOURCE_DIR}/rofi-themes-collection"
    git clone https://github.com/lr-tech/rofi-themes-collection.git "${rofi_theme}"
    cd "${rofi_theme}"
    mkdir -p ~/.local/share/rofi/themes/
    cp themes/spotlight ~/.local/share/rofi/themes/

    echo run -> rofi-theme-selector
    echo "Choose Alt + a on selected node"

}

alias_tips
picom
i3lock
rofi
