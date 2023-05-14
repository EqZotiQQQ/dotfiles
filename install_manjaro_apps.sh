#!/usr/bin/env bash

OPEN_SOURCE_DIR="${HOME}/open_source"
mkdir -p "${OPEN_SOURCE_DIR}"

sudo pacman -Syy --needed \
    git base-devel \
    kitty ripgrep \
    fzf rofi picom \
    rustup luajit lua51 \
    lua luarocks bash-language-server \
    flameshot neovim htop \
    lua-posix cmake make \
    feh pavucontrol discord

sudo pacman -S base-devel fftw ncurses alsa-lib iniparser pulseaudio autoconf-archive

sudo pacman -Syy --needed \
    docker \
    docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:`whoami`:rw /var/run/docker.sock


git config --global merge.tool vimdiff

mkdir -p ${HOME}/Pictures/Screenshots


cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -S --needed cava pycharm-professional i3lock-color


sudo luarocks --lua-version 5.3 install lua-lsp
sudo luarocks --lua-version 5.3 install luaposix
sudo luarocks --lua-version 5.1 install luafilesystem
sudo luarocks --lua-version 5.1 install bit32

rofi_theme_download_dir="${OPEN_SOURCE_DIR}/rofi-themes-collection"
rofi_themes_dst_dir="${HOME}/.local/share/rofi/themes/"
git clone https://github.com/lr-tech/rofi-themes-collection.git "${rofi_theme_download_dir}"
mkdir -p "${rofi_themes_dst_dir}"
cp -r "${rofi_theme_download_dir}/themes/" "${rofi_themes_dst_dir}"
echo run -> rofi-theme-selector
echo "Choose Alt + a on selected node"


rustup install stable
rustup default stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

echo "Required 800010003-5"
paru -S snx awesome-git ffmpeg-git xorg-server-xephyr
sudo modprobe tun
echo "Go to bagazhnik and take binary file. Put it to ${HOME}/.cache/paru/clone/snx then execute from root" 

ssh-keygen -t rsa
yay -S python38
# To install SNX - install 

yay -S awesome-freedesktop-git

git config --global merge.tool vimdiff

# Configure automount sudo mount -t ntfs /dev/sdb1(autodetect part-s) /mnt