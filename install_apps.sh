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
  postgresql-server-dev-all \
  libmariadbclient-dev      \
  libmariadbclient-dev      \
  clang-12                  \
  lldb-12                   \
  lld-12                    \
  libmariadb-dev \
  lightdm \
  i3lock imagemagick scrot \
  autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
  libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev \
  libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev \
   libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev \
  linux-tools-$(uname -r) \
  libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson \
  maim\
  frei0r-plugins


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

specific_apps=(git zsh kitty)
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
sudo snap install notion-snap
