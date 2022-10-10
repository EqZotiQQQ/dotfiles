#!/usr/bin/env bash

sudo apt update
sudo apt upgrade -y

sudo apt install -y         \
  curl                      \
  htop                      \
  openssh-server            \
  gcc                       \
  make                      \
  zlib1g-dev                \
  cmake                     \
  clang                     \
  vim                       \
  neovim                    \
  awesome-extra             \
  feh                       \
  libssl-dev                \
  zsh                       \
  kitty                     \
  python3                   \
  python3-pip               \
  default-jdk               \
  openssl                   \
  tree                      \
  zsh-autosuggestions       \
  g++                       \
  libjsoncpp-dev            \
  uuid-dev                  \
  docker                    \
  docker-compose            \
  bash                      \
  lua                       \
  postgresql-server-dev-all \
  libmariadbclient-dev      \
  libmariadbclient-dev      \
  clang-12                  \
  lldb-12                   \
  lld-12                    \
  gcc-11                    \
  libxext-dev               \  # {{{ Picom dependencies
  libxcb1-dev               \
  libxcb-damage0-dev        \
  libxcb-xfixes0-dev        \
  libxcb-shape0-dev         \
  libxcb-render-util0-dev   \
  libxcb-render0-dev        \
  libxcb-randr0-dev         \
  libxcb-composite0-dev     \
  libxcb-image0-dev         \
  libxcb-present-dev        \
  libxcb-xinerama0-dev      \
  libxcb-glx0-dev           \
  libpixman-1-dev           \
  libdbus-1-dev             \
  libconfig-dev             \
  libgl1-mesa-dev           \
  libpcre2-dev              \
  libpcre3-dev              \
  libevdev-dev              \
  uthash-dev                \
  libev-dev                 \
  libx11-xcb-dev            \
  meson                     \ # }}}
  lightdm \ # lightdm
  i3lock imagemagick scrot \ # lockscreen
  autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
  libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev \
  libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev \
   libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev \ # i3lock color
  linux-tools-$(uname -r)


function configure_git() {
    git config --global merge.tool vimdiff
    git config --global user.name "Mikhail Fedyakov"
    git config --global user.email mf_52@mail.ru
    git config --global core.editor "vim"
}

function configure_zsh() {
    chsh -s $(which zsh)
}

function configure_kitty() {
    cd .fonts
    fc-cache -fv
}

function configure_picom() {
    git clone https://github.com/yshui/picom.git "${HOME}/open_source/picom"
    cd "${HOME}/open_source/picom"
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
}

function configure_i3lock() {
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

specific_apps=(git zsh kitty picom i3lock)
for app in "${specific_apps[@]}"; do
    cd ~
    status=$(package_installed $app)
    echo "status = $status"
    if [ "$status" = "$app installed" ]; then
        configure_$app
    fi
done

sudo snap install telegram-desktop
sudo snap install clion --classic
sudo snap install pycharm-community --classic
sudo snap install vlc
sudo snap install chromium
sudo snap install discord