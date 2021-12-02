#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "Dotfiles dir location: $DOTFILES_DIR"

. ./utils.sh --source-only

GREEN='\033[0;32m' # GREEN
RED='\033[0;31m' # RED
NC='\033[0m' # No Color

while [ $# -gt 0 ]
do
    key="$1"
    case $key in
        -c|--compton)
            COMPTON=yes
            shift
            ;;
        -d|--debug)
            DEBUG=yes
            shift
            ;;
        -s|--symlinks)
            SYMLINK=yes
            shift
            ;;
        *)
    esac
done

function configure_git() {
    # TODO check is git configured
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

function update_symlinks() {
    update_symlinks_impl $DOTFILES_DIR/home $HOME
}

if [[ $SYMLINK = yes ]]; then
    update_symlinks
    exit
fi

sudo apt update
sudo apt upgrade -y

apps=("curl" "htop" "openssh-server" "gcc" "make"
  "cmake" "clang" "vim" "neovim" "awesome-extra" "feh"
  "zsh" "kitty" "python3" "python3-pip" "default-jdk"
  "tree")
for app in "${apps[@]}"; do
    install_app $app
done

specific_apps=("zsh" "kitty")
for app in "${specific_apps[@]}"; do
    cd ~
    status=$(package_installed $app)
    echo "status = $status"
    if [ "$status" = "$app installed" ]; then
        configure_$app
    fi
done

# TODO: Think about that
sudo snap install telegram-desktop
sudo snap install clion --classic
sudo snap install vlc
sudo snap install spotify

# TODO: move out from this file
mkdir $HOME/open_source
cd $HOME/open_source
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest


update_symlinks

# TODO: same as for emsdk
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:ctrl_shift_toggle']"

# TODO: setup autosuggestions for builtin apps
sudo apt-get install zsh-autosuggestions -y
