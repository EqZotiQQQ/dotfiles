
function alias_tips() {
    git clone https://github.com/djui/alias-tips.git "${HOME}/open_source/alias-tips"
}


function picom() {
    git clone https://github.com/yshui/picom.git "${HOME}/open_source/picom"
    cd "${HOME}/open_source/picom"
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
}

function i3lock() {
    # Previously we installed i3lock, which provides beauty lock screen
    git clone https://github.com/Raymo111/i3lock-color.git "${HOME}/open_source/i3lock-color"
    cd "${HOME}/open_source/i3lock-color"
    ./build.sh
    ./install-i3lock-color.sh

    # Fix and config for i3lock-color https://github.com/noctuid/multilockscreen
    git clone https://github.com/jeffmhubbard/multilockscreen "${HOME}/open_source/multilockscreen"
    cd "${HOME}/open_source/multilockscreen"
    sudo install -Dm 755 multilockscreen /usr/bin/multilockscreen

    multilockscreen -u ${HOME}/Pictures/witcher.png
}


mkdir -p "${HOME}/open_source"

alias_tips
picom
i3lock
