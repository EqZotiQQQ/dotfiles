#!/bin/bash
DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Dot dir location: $DOTFILES_DIR"

. ./utils.sh --source-only

while [ $# -gt 0 ]
do
    key="$1"
    case $key in
        -z|--zsh)
            ZSH=yes
            shift
            ;;
        -c|--compton)
            COMPTON=yes
            shift
            ;;
        -d|--debug)
            DEBUG=yes
            shift
            ;;
        *)
    esac
done



function cava() {
#https://github.com/karlstav/cava
    echo "###### installing cava #######"
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
    cd luarocks-3.3.1
    ./configure
    makeinstall_neovimks install luasocket
#https://github.com/luaposix/luaposix
    cd $HOME/git/tools
    git clone https://github.com/luaposix/luaposix.git $HOME/git/tools/luaposix
    cd luaposix
    sudo luarocks install luaposix
    cd $HOME/git/tools/cava
    sudo make
    sudo make install
}

#its under testing. If it wont work do it by ur hands
function compton() {
    echo "###### installing compton #######"
    sudo apt install -y libxcomposite-dev libxdamage-dev libxrender-dev libxrandr-dev libxinerama-dev libconfig-dev libdbus-1-dev libglx-dev libgl-dev libdrm-dev asciidoc libpcre3-dev
    mkdir -p $HOME/git/other
    git clone https://github.com/tryone144/compton.git $HOME/git/tools/compton
    cd $HOME/git/tools/compton
    sudo make
    sudo make docks
    sudo make install
    #https://www.reddit.com/r/voidlinux/comments/capd59/how_do_i_install_compton_fork_tryone144
    vm_check=$(is_vm)
    if [ $vm_check = 1 ]; then
        ln -sf $DOTFILES_DIR/.config/compton_vm.conf $HOME/.config/compton.conf
    else
        ln -sf $DOTFILES_DIR/.config/compton_real.conf $HOME/.config/compton.conf
    fi
    echo "###### compton installed ########"
    cava
}


function debug() {
    echo "debug begin"

    exit 0
}

function configure_git() {
    git config --global merge.tool vimdiff
    git config --global user.name "Mikhail Fedyakov"
    git config --global user.email mf_52@mail.ru
    git config --global core.editor "vim"
}

function unustall() {
    # TODO remove all items, that were installed by this script
}

sudo apt update
sudo apt upgrade -y
sudo apt install -y curl htop openssh-server gcc make cmake clang 

function install_neovim() {
    echo "###### installing neovim ... ######"
    ubuntu_version=$(get_ubuntu_version)
    udo apt install -y neovim
    mkdir $HOME/.config/nvim
    ln -sf $DOTFILES_DIR/.config/nvim/autocmd.vim $HOME/.config/nvim/autocmd.vim
    ln -sf $DOTFILES_DIR/.config/nvim/bindings.vim $HOME/.config/nvim/bindings.vim
    ln -sf $DOTFILES_DIR/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
    ln -sf $DOTFILES_DIR/.config/nvim/init.vim $HOME/.config/nvim/init.vim
    ln -sf $DOTFILES_DIR/.config/nvim/plugins.vim $HOME/.config/nvim/plugins.vim
    echo "###### installation done #######"
}

function install_zsh() {
    sudo apt install -y zsh
    mkdir -p $HOME/.config/zsh
    ln -sf $DOTFILES_DIR/.config/zsh/compl.d $HOME/.config/zsh/compl.d
    ln -sf $DOTFILES_DIR/.config/zsh/plugins.zsh $HOME/.config/zsh/plugins.zsh
    ln -sf $DOTFILES_DIR/.config/zsh/settings $HOME/.config/zsh/settings
    ln -sf $DOTFILES_DIR/.config/zsh/.zprofile $HOME/.config/zsh/.zprofile
    ln -sf $DOTFILES_DIR/.zshenv $HOME/
    chsh -s $(which zsh)
}

function install_kitty() {
    sudo apt install kitty
    ln -sf $DOTFILES_DIR/.config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf
    ln -sf $DOTFILES_DIR/.fonts $HOME/.fonts 
    cd .fonts
    fc-cache -fv
}

function install_awesome-extra() {
    sudo apt install -y awesome-extra feh
    ln -sf /$DOTFILES_DIR/.config/awesome $HOME/.config/awesome
    ln -sf /$DOTFILES_DIR/.xinitrc $HOME/.xinitrc
}

apps=("neovim" "zsh" "vim" "awesome-extra")

for app in "${apps[@]}"; do
    cd ~
    status=$(package_installed $app)
    echo "status = $status"
    if [ "$status" = "$app installed" ]; then
        echo "Package $app already installed"
    else
        echo "Install $app"
        install_$app
    fi
done


if [ "$COMPTON" = "yes" ]; then
    compton
fi

if [ "$DEBUG" = "yes" ]; then
    debug
fi


rm -rf $HOME/Pictures
ln -sf $DOTFILES_DIR/Pictures $HOME/Pictures
ln -sf $DOTFILES_DIR/.profile $HOME/.profile
ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile

# sudo apt install -y python python3 python3-pip default-jdk
# pip3 install numpy scipy opencv-python
# compton
