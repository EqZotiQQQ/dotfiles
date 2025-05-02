#!/usr/bin/env bash

# Sys update & base stuff
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel

# Directories
open_source_dir="${HOME}/open_source"
mkdir -p "${open_source_dir}"
mkdir -p ${HOME}/Pictures/Screenshots

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable

# AUR helpers
## paru
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

## yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si


# sys libs and dependencies
paru -S --skipreview --noconfirm fftw ncurses alsa-lib iniparser pulseaudio autoconf-archive

# build & dev utils
paru -S --skipreview --noconfirm cmake make bash-language-server luarocks

# environment, shell
paru -S --skipreview --noconfirm zsh kitty rofi picom-git terminator fzf

# editors, interprers
paru -S --skipreview --noconfirm visual-studio-code-bin pycharm-professional neovim lua lua53 python38

# default items replacement
paru -S --skipreview --noconfirm exa bat duf ripgrep

# multimedia & audio
paru -S --skipreview --noconfirm pavucontrol cava-git feh

# sys utilities
paru -S --skipreview --noconfirm htop flameshot i3lock-color

# desctop env, WM
paru -S --skipreview --noconfirm awesome-git awesome-freedesktop xorg-server-xephyr

# browser, communiction
paru -S --skipreview --noconfirm discord telegram-desktop-git google-chrome

# java
paru -S --skipreview --noconfirm jdk-openjdk

# docker
paru -S --skipreview --noconfirm docker docker-compose

# zsh configuration
chsh -s $(which zsh)
## powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc -> moved to zsh configuration
## oh my zsh -> too heavy
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"


# configuring font
curl -s https://api.github.com/repos/be5invis/Iosevka/releases/latest | grep ".*browser_download_url.*PkgTTC-Iosevka-.*.zip" | cut -d '"' -f 4 | xargs curl -L -o iosevka-ttf.zip
unzip iosevka-ttf.zip -d iosevka-ttf
mkdir -p ~/.local/share/fonts/iosevka
cp iosevka-ttf/* ~/.local/share/fonts/iosevka/
fc-cache -f -v


# astrovim setup
# https://astronvim.com/
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim

# Docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:`whoami`:rw /var/run/docker.sock

# Git configuration
git config --global merge.tool vimdiff
git config --global core.editor nvim

# lua modules
sudo luarocks --lua-version 5.3 install lua-lsp ;\
sudo luarocks --lua-version 5.3 install luaposix ;\
sudo luarocks --lua-version 5.1 install luafilesystem ;\
sudo luarocks --lua-version 5.1 install bit32

# Rofi themes
rofi_theme_download_dir="${open_source_dir}/rofi-themes-collection"
rofi_themes_dst_dir="${HOME}/.local/share/rofi/themes/"
git clone https://github.com/lr-tech/rofi-themes-collection.git "${rofi_theme_download_dir}"
mkdir -p "${rofi_themes_dst_dir}"
cp -r "${rofi_theme_download_dir}/themes/" "${rofi_themes_dst_dir}"
echo run -> rofi-theme-selector
echo "Choose Alt + a on selected node"

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
