#!/usr/bin/env bash

sudo pacman -Syu --noconfirm

open_source_dir="${HOME}/open_source"
mkdir -p "${open_source_dir}"

sudo pacman -S --needed --noconfirm base-devel

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S --skipreview --noconfirm visual-studio-code-bin kitty rofi lua picom-git luarocks neovim htop bash-language-server discord cmake make feh pavucontrol discord fftw ncurses alsa-lib iniparser pulseaudio autoconf-archive

paru -S --skipreview --noconfirm cava-git pycharm-professional i3lock-color flameshot lua53 5.3.6-1 

paru -S --skipreview --noconfirm awesome-git xorg-server-xephyr awesome-freedesktop python38

paru -S --skipreview --noconfirm  telegram-desktop-git 

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

paru -S --skipreview --noconfirm google-chrome

paru -S --skipreview --noconfirm docker docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:`whoami`:rw /var/run/docker.sock

git config --global merge.tool vimdiff

mkdir -p ${HOME}/Pictures/Screenshots

sudo luarocks --lua-version 5.3 install lua-lsp ;\
sudo luarocks --lua-version 5.3 install luaposix ;\
sudo luarocks --lua-version 5.1 install luafilesystem ;\
sudo luarocks --lua-version 5.1 install bit32

rofi_theme_download_dir="${open_source_dir}/rofi-themes-collection"
rofi_themes_dst_dir="${HOME}/.local/share/rofi/themes/"
git clone https://github.com/lr-tech/rofi-themes-collection.git "${rofi_theme_download_dir}"
mkdir -p "${rofi_themes_dst_dir}"
cp -r "${rofi_theme_download_dir}/themes/" "${rofi_themes_dst_dir}"
echo run -> rofi-theme-selector
echo "Choose Alt + a on selected node"


echo "Required 800010003-5"
paru -S --skipreview snx

sudo modprobe tun
echo "Go to bagazhnik and take binary file. Put it to ${HOME}/.cache/paru/clone/snx then execute from root" 

ssh-keygen -t rsa
# To install SNX - install 

git config --global merge.tool vimdiff

# Configure automount sudo mount -t ntfs /dev/sdb1(autodetect part-s) /mnt