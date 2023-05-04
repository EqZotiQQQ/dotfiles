#!/usr/bin/env bash

git submodule update --init --recursive

mkdir -p ${HOME}/open_source

sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt upgrade -y


# C++ Compilers
sudo apt install -y \
    gcc \
    clang


# C++ build tools
sudo apt install -y \
    cmake \
    make \
    ninja-build \
    meson \
    libstdc++-12-dev \
    libstdc++-11-dev \
    libc++abi-14-dev # clang libc


# Py tools
sudo apt install -y \
    python3-pip python3.10-distutils \
    python3.8 python3.8-dev python3.8-venv python3.8-distutils python3.8-dbg \
    graphviz



# lua
sudo apt install -y \
    lua-posix \
    luarocks


# Kitty term
sudo apt install -y \
    kitty \
    feh
cd $HOME/.fonts
fc-cache -fv # scan font dir and generate font cache


# Awesome wm
sudo apt install -y \
    awesome-extra


# zsh
sudo apt install -y \
    zsh \
    zsh-autosuggestions
chsh -s $(which zsh) # set zsh by default


# docker related
sudo apt install -y \
    docker \
    docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:`whoami`:rw /var/run/docker.sock


# git
sudo apt install -y \
    git
git config --global merge.tool vimdiff


# neovim
sudo apt install -y \
    neovim


# screenshot tool
sudo apt install -y \
    flameshot
mkdir -p ${HOME}/Pictures/Screenshots


# perf
sudo apt install -y \
    linux-tools-$(uname -r)


# Rust
sudo apt install -y \
    curl \
    build-essential


# Utils
sudo apt install -y \
    htop \
    net-tools


# Beauty login screens
sudo apt install -y \
    lightdm

# Xorg server
sudo apt install -y \
    xorg-server-source

# Ssl chrome fix
sudo apt install -y \
    ssl-cert-check

# audio
sudo apt install -y \
    pavucontrol

sudo snap install telegram-desktop
sudo snap install vlc
sudo snap install discord
