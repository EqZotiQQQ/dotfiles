
OPEN_SOURCE_DIR="${HOME}/open_source"
mkdir -p "${OPEN_SOURCE_DIR}"

function alias_tips() {
    git clone https://github.com/djui/alias-tips.git "${OPEN_SOURCE_DIR}/alias-tips"
}

function picom() {
    picom_path="${OPEN_SOURCE_DIR}/picom"
    git clone https://github.com/yshui/picom.git $picom_path
    cd $picom_path
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
}

function i3lock() {
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


alias_tips
picom
i3lock
