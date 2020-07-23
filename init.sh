#!/bin/bash
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
            echo "----- debug -----"
            shift
            ;;
        *)
    esac
done

function is_vm() {
    host=`sudo dmidecode -s system-manufacturer`
    if [ "$host" = "innotek GmbH" ]
    then
        echo "1"
    else
        echo "0"
    fi
}

function get_ubuntu_version() {
    version=`cat /etc/lsb-release`
    version=$(echo $version| cut -d'=' -f 5)
    if [ "$version" = "\"Ubuntu 20.04 LTS\"" ]; then
        echo "20"
    else 
        echo "18"
    fi
}

function zsh_install() {
    echo "###### installing zsh #######"
    sudo apt update
    sudo apt install -y zsh
    mkdir $HOME/.config/zsh
    ln -sf $DOTFILES_DIR/.config/zsh/compl.d $HOME/.config/zsh/compl.d
    ln -sf $DOTFILES_DIR/.config/zsh/plugins.zsh $HOME/.config/zsh/plugins.zsh
    ln -sf $DOTFILES_DIR/.config/zsh/settings $HOME/.config/zsh/settings
    ln -sf $DOTFILES_DIR/.config/zsh/.zprofile $HOME/.config/zsh/.zprofile
    ln -sf $DOTFILES_DIR/.config/zsh/.zshrc $HOME/.config/zsh/.zshrc
    ln -sf $DOTFILES_DIR/.zshenv $HOME/.zshenv
    chsh -s $(which zsh)
    echo "###### installation done #######"
}

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
    make
    sudo make install
    sudo luarocks install luasocket
#https://github.com/luaposix/luaposix
    cd $HOME/git/tools
    git clone https://github.com/luaposix/luaposix.git $HOME/git/tools/luaposix
    cd luaposix
    sudo luarocks install luaposix
    cd $HOME/git/tools/cava
    sudo make
    sudo make install
}

#its under testings. If it wont work do it by ur hands
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


function rec_links() {
    # TODO: make copying smart again
    # $1 - dir from 
    # $2 - dir to
    if [ ! -d $DOT_OLD ]; then 
        mkdir -p $DOT_OLD
    fi
    for file in $( ls -a $1)
    do
        if [ $file = '..' ] || [ $file = '.' ] || [ $file = '.git' ]; then
            continue
        fi
        if [ -f "$1/$file" ]; then 
            rm "$2/$file"
            ln -sf "$1/$file" "$2/$file"
        else
        rm -rf "$2/$file"
        mkdir -p "$2/$file"
            rec_links "$1/$file" "$2/$file"
        fi
    done
}

install_neovim() {
    echo "###### installing neovim ... ######"
    ubuntu_version=$(get_ubuntu_version)
    udo apt install -y neovim
    if [ "$ubuntu_version" = 18 ]; then
        echo "Ubuntu 18 found!"
        curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
        sudo chmod 777 nvim.appimage
        sudo rm /usr/bin/nvim
        sudo rm /usr/bin/vim
        sudo cp $DOTFILES_DIR/nvim.appimage /usr/bin/nvim
        sudo cp /usr/bin/nvim /usr/bin/vim
        sudo rm $DOTFILES_DIR/nvim.appimage
    else
        echo "Ubuntu 20 found!"
    fi
    # TODO: Rework following lines. No need to gen it if u have no ubuntu
    mkdir $HOME/.config/nvim
    ln -sf $DOTFILES_DIR/.config/nvim/autocmd.vim $HOME/.config/nvim/autocmd.vim
    ln -sf $DOTFILES_DIR/.config/nvim/bindings.vim $HOME/.config/nvim/bindings.vim
    ln -sf $DOTFILES_DIR/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
    ln -sf $DOTFILES_DIR/.config/nvim/init.vim $HOME/.config/nvim/init.vim
    ln -sf $DOTFILES_DIR/.config/nvim/plugins.vim $HOME/.config/nvim/plugins.vim
    echo "###### installation done #######"
}


function debug() {
    echo "debug begin"
    
    exit 0
}

if [ "$ZSH" = "yes" ]; then
    zsh_install
fi

if [ "$COMPTON" = "yes" ]; then 
    compton
fi

if [ "$DEBUG" = "yes" ]; then
    debug
fi

sudo apt update
sudo apt upgrade -y
sudo apt install -y curl htop openssh-server gcc make cmake clang 

install_neovim

echo "###### installing git... #######"
sudo apt install -y git
git config --global merge.tool vimdiff
#git config --global user.name "Mikhail Fedyakov"
#git config --global user.email mf_52@mail.ru
git config --global core.editor "vim"
# git config credential.helper store
echo "###### installation done #######"


echo "###### installing awesome ... #######"
sudo apt install -y awesome-extra feh
ln -sf /$DOTFILES_DIR/.config/awesome $HOME/.config/awesome
ln -sf /$DOTFILES_DIR/.xinitrc $HOME/.xinitrc


echo "###### installing kitty ... ######"
cd ~
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

if [ ! -d "$HOME/.local/lib" ]; then 
    mkdir -p "$HOME/.local/lib"
fi

cp -rf $HOME/.local/kitty.app/share/* $HOME/.local/share/
cp -rf $HOME/.local/kitty.app/bin/* $HOME/.local/bin/
cp -rf $HOME/.local/kitty.app/lib/* $HOME/.local/lib/

export PATH=$PATH:$HOME/.local/bin

ln -sf $DOTFILES_DIR/.config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

echo "###### setting fonts for Kitty term ######"
cd ~
ln -sf $DOTFILES_DIR/.fonts $HOME/.fonts 
cd .fonts 
fc-cache -fv 
cd ~
echo "####### AwesomeWM and Kitty term installed"

rm -rf $HOME/Pictures
ln -sf $DOTFILES_DIR/Pictures $HOME/Pictures
ln -sf $DOTFILES_DIR/.profile $HOME/.profile
ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile

#sudo apt install -y python3
#sudo apt install -y python3-pip
#sudo apt install -y default-jdk

compton
zsh_install
