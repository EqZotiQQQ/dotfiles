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
  "tree" "zsh-autosuggestions")
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


gsettings set org.gnome.desktop.input-sources xkb-options "['grp:ctrl_shift_toggle']"

# TODO: Think about that
sudo snap install telegram-desktop
sudo snap install clion --classic
sudo snap install vlc
sudo snap install spotify


update_symlinks

function install_from_source_emsdk() {
    # TODO: move out from this file
    mkdir $HOME/open_source
    cd $HOME/open_source
    git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk
    ./emsdk install latest
    ./emsdk activate latest
}

function install_from_source_poco() {
    # TODO: same as for emsdk
    cd $HOME/open_source
    git clone -b master https://github.com/pocoproject/poco.git
    cd poco
    mkdir cmake-build
    cd cmake-build
    cmake ..
    cmake --build . --config Release -j16
    sudo cmake --build . --target install -j16
}

function install_from_source_bison() {
    sudo apt install libboost-all-dev flex bison m4 libboost-all-dev
    wget http://ftp.gnu.org/gnu/bison/bison-3.7.tar.gz
    tar -xvzf bison-3.7.tar.gz
    cd bison-3.7
    PATH=$PATH:/usr/local/m4
    ./configure --prefix=/usr/local/bison --with-libiconv-prefix=/usr/local/libiconv/
    make
    sudo make install
    cp src/bison /usr/bin/bison 
}


# install some rust shit
function install_from_source_exa() {
    cd ~/open_source
    git clone https://github.com/ogham/exa.git
    cd exa
    cargo build --release
    cp ./target/release/exa /usr/local/bin
    cp ./man/exa.1.md /usr/share/man/man1
    cp ./man/exa_colors.5.md /usr/share/man/man5
    mkdir -p /usr/local/share/zsh/site-functions
    cp ./completions/zsh/_exa /usr/local/share/zsh/site-functions/
}