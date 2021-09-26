#!/bin/bash
DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Dot dir location: $DOTFILES_DIR"

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


function cava() {
#https://github.com/karlstav/cava
    sudo apt install lua5.3 liblua5.3-dev libfftw3-dev libasound2-dev libncursesw5-dev libpulse-dev libtool automake libiniparser-dev make
    export CPPFLAGS=-I/usr/include/iniparser
    mkdir -p $HOME/git/tools
    git clone https://github.com/karlstav/cava.git $HOME/git/tools/cava
    cd $HOME/git/tools/cava/
    ./autogen.sh
    ./configure
    cd $HOME/git/tools
#https://luarocks.org/
    wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
    tar zxpf luarocks-3.3.1.tar.gz
    cd luarocks-3.3.1(
    shopt -s dotglob
    for item in $1; do
        printf "${RED}$item to $1${NC}\n"
    done
)x.git $HOME/git/tools/luaposix
    cd luaposix
    sudo luarocks install luaposix
    cd $HOME/git/tools/cava
    sudo make
    sudo make install
}

#its under testing. If it wont work do it by ur hands
function compton() {
function update_symlinks() (
  shopt -s dotglob(
    shopt -s dotglob
    for item in $1; do
        printf "${RED}$item to $1${NC}\n"
    done
)
  ln -sf $DOTFILES_DIR/Pictures $HOME/Pictures
  ln -sf $DOTFILES_DIR/.profile $HOME/.profile
  ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
  ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile
  ln -sf $DOTFILES_DIR/.config/awesome $HOME/.config/awesome
  ln -sf $DOTFILES_DIR/.xinitrc $HOME/.xinitrc
  ln -sf $DOTFILES_DIR/.zshenv $HOME/
)r/voidlinux/comments/capd59/how_do_i_install_compton_fork_tryone144
    vm_check=$(is_vm)
    if [ $vm_check = 1 ]; then
        ln -sf $DOTFILES_DIR/.config/compton_vm.conf $HOME/.config/compton.conf
    else
        ln -sf $DOTFILES_DIR/.config/compton_real.conf $HOME/.config/compton.conf
    fi
    cava
}

function configure_git() {
    git config --global merge.tool vimdiff
    git config --global user.name "Mikhail Fedyakov"
    git config --global user.email mf_52@mail.ru
    git config --global core.editor "vim"
}

function install_zsh() {
    sudo apt install -y zsh
    chsh -s $(which zsh)
}

function install_kitty() {
    sudo apt install kitty
    ln -sf $DOTFILES_DIR/.fonts $HOME/.fonts 
    cd .fonts
    fc-cache -fv
}

function update_symlinks() (
  shopt -s dotglob
  for item in $DOTFILES_DIR/.config/*; do 
    folder_name=$(echo $item | cut -d'/' -f 7)
    printf "${RED}Creating symlinks for $folder_name${NC}\n"
    rm -rf "$HOME/.config/$folder_name"
    mkdir "$HOME/.config/$folder_name"
    update_sym_links $item $HOME/.config/$folder_name
  done
  rm $HOME/Pictures
  ln -sf $DOTFILES_DIR/Pictures $HOME/Pictures
  ln -sf $DOTFILES_DIR/.profile $HOME/.profile
  ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
  ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile
  ln -sf $DOTFILES_DIR/.config/awesome $HOME/.config/awesome
  ln -sf $DOTFILES_DIR/.xinitrc $HOME/.xinitrc
  ln -sf $DOTFILES_DIR/.zshenv $HOME/
)

if [[ $SYMLINK = yes ]]; then
    update_symlinks
     exit
fi

sudo apt update
sudo apt upgrade -y

apps=("curl" "htop" "openssh-server" "gcc" "make" "cmake" "clang" "vim" "neovim" "awesome-extra" "feh")
for app in "${apps[@]}"; do
    cd ~
    status=$(package_installed $app)
    echo "status = $status"
    if [ "$status" = "$app installed" ]; then
        printf "${GREEN}Package $app already installed${NC}\n"
    else
        printf "${RED}Install $app${NC}\n"
        sudo apt install -y $app
    fi
done

specific_apps=("zsh" "kitty")
for app in "${specific_apps[@]}"; do
    cd ~
    status=$(package_installed $app)
    echo "status = $status"
    if [ "$status" = "$app installed" ]; then
        printf "${GREEN}Package $app already installed${NC}\n"
    else
        printf "${RED}Install $app${NC}\n"
        install_$app
    fi
done

rm -rf $HOME/Pictures


# sudo apt install -y python python3 python3-pip default-jdk
# pip3 install numpy scipy opencv-python
# compton

update_symlinks

sudo snap install telegram-desktop
