# dotfiles_dir contains path to this dir
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo apt update

while [ $# -gt 0 ] 
do
    key="$1"
    case $key in
        -z|--zsh)
            ZSH=yes
            shift
            ;;
        -a|--awesome)
            AWESOME=yes
            shift
            ;;
        *)
    esac
done

sudo apt upgrade -y
sudo apt install curl htop openssh-server gcc make cmake clang git repo ncdu libx11-dev libxcomposite-dev libxdamage-dev libxrender-dev\
        libxrandr-dev libxinerama-dev libconfig-dev dbus libdbus-1-dev libdbus-glib-1-2 libdbus-glib-1-dev apt-file libglx-dev libgl-dev\
        libdrm-dev asciidoc-base libcairo2-dev libxcb-composite0-dev libxcb-randr0-dev xcb-proto libxcb-util0-dev libxcb1-dev\
        python3-xcbgen libxcb-icccm4-dev libxcb-ewmh-dev libxcb-image0-dev python-xcbge
sudo apt-file update

########################################
# NEOVIM
########################################
function nvim {
###### use it with Ubuntu < 20.
#    sudo apt install -y neovim
#    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
#    sudo chmod 777 nvim.appimage
#    sudo rm /usr/bin/nvim
#    sudo rm /usr/bin/vim
#    sudo cp $DOTFILES_DIR/nvim.appimage /usr/bin/nvim
#    sudo cp /usr/bin/nvim /usr/bin/vim
#    sudo rm $DOTFILES_DIR/nvim.appimage

    mkdir $HOME/.config/nvim
    ln -sf $DOTFILES_DIR/.config/nvim/autocmd.vim $HOME/.config/nvim/autocmd.vim
    ln -sf $DOTFILES_DIR/.config/nvim/bindings.vim $HOME/.config/nvim/bindings.vim
    ln -sf $DOTFILES_DIR/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
    ln -sf $DOTFILES_DIR/.config/nvim/init.vim $HOME/.config/nvim/init.vim
    ln -sf $DOTFILES_DIR/.config/nvim/plugins.vim $HOME/.config/nvim/plugins.vim
}

function git {
    git config --global merge.tool vimdiff
    git config --global user.name "Mikhail Fedyakov"
    git config --global user.email mf_52@mail.ru
    git config --global core.editor "vim"
    # git config credential.helper store
}


function awesome_install {

    ####################################
    # AwesomeWM
    ####################################
    sudo apt install -y awesome-extra feh #lightdm
    mkdir $HOME/.config/awesome
    cp /etc/xdg/awesome $HOME/.config/awesome
    ln -sf /$DOTFILES_DIR/.config/awesome $HOME/.config/awesome
    ln -sf /$DOTFILES_DIR/.xinitrc $HOME/.xinitrc

    ####################################
    # Kitty
    ####################################

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

    # Fonts for Kitty
    cd ~
    ln -sf $DOTFILES_DIR/.fonts $HOME/.fonts 
    cd .fonts 
    fc-cache -fv 
    cd ~
}

function update_symlinks {
# set Links
    ln -sf $DOTFILES_DIR/Wallpaper $HOME/Pictures
    ln -sf $DOTFILES_DIR/.profile $HOME/.profile
    ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
    ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile
}

function zsh_install {
    ########################################
    # zsh
    ########################################

    sudo apt install -y zsh
    mkdir $HOME/.config/zsh
    ln -sf $DOTFILES_DIR/.config/zsh/compl.d $HOME/.config/zsh/compl.d
    ln -sf $DOTFILES_DIR/.config/zsh/plugins.zsh $HOME/.config/zsh/plugins.zsh
    ln -sf $DOTFILES_DIR/.config/zsh/settings $HOME/.config/zsh/settings
    ln -sf $DOTFILES_DIR/.config/zsh/.zprofile $HOME/.config/zsh/.zprofile
    ln -sf $DOTFILES_DIR/.config/zsh/.zshrc $HOME/.config/zsh/.zshrc
    ln -sf $DOTFILES_DIR/.zshenv $HOME/.zshenv
    chsh -s $(which zsh)
}

#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#source $HOME/.cargo/env
#cargo install exa

# set Python 
function python {
    sudo apt install -y python3
    sudo apt install -y python3-pip
    sudo apt install -y python-pip
    pip install neovim
    pip3 install neovim

    #sudo pip3 install python3-matplotlib
    #sudo pip3 install numpy
    #sudo pip3 install pandas
    #pip3 install -U scikit-learn
}

#its under testings. If it wont work do it by ur hands
function compton {
    mkdir -p $HOME/git/other
    git clone https://github.com/tryone144/compton.git $HOME/git/other
    make -C $HOME/git/other/compton
    make docks -C $HOME/git/other/compton
    make install -C $HOME/git/other/compton
    #https://www.reddit.com/r/voidlinux/comments/capd59/how_do_i_install_compton_fork_tryone144/
}

function polybar {
    mkdir -p $HOME/git/other
    git clone https://github.com/polybar/polybar.git $HOME/git/other
    mkdir $HOME/git/other/polybar/build
    cd $HOME/git/other/polybar/build
    cmake ..
    make -j4
    sudo make install
    # https://github.com/polybar/polybar/wiki/Compiling
}
# set Java
# sudo apt install -y default-jdk

git
nvim
awesome_install
python
update_symlinks
compton
#polybar

if [ $ZSH = yes ]; then
    zsh_install
fi
