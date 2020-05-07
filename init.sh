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
sudo apt install -y curl htop openssh-server gcc make cmake clang git repo ncdu

########################################
# NEOVIM
########################################
function nvim {
    sudo apt install -y neovim
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
    chmod u+x nvim.appimage
	rm /usr/bin/nvim
	rm /usr/bin/vim
	cp nvim.appimage /usr/bin/nvim
    cp /usr/bin/nvim /usr/bin/vim

    mkdir $HOME/.config/nvim
    ln -sf $DOTFILES_DIR/.config/nvim/autocmd.vim $HOME/.config/nvim/autocmd.vim
    ln -sf $DOTFILES_DIR/.config/nvim/bindings.vim $HOME/.config/nvim/bindings.vim
    ln -sf $DOTFILES_DIR/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
    ln -sf $DOTFILES_DIR/.config/nvim/init.vim $HOME/.config/nvim/init.vim
    ln -sf $DOTFILES_DIR/.config/nvim/plugins.vim $HOME/.config/nvim/plugins.vim
}

function git {
    it config --global merge.tool vimdiff
    it config --global user.name "Mikhail Fedyakov"
    it config --global user.email mf_52@mail.ru
    it config --global core.editor "vim"
}

function awesome_install {

    ####################################
    # Awesome WM 
    ####################################

    sudo apt install -y awesome
    sudo apt install -y lightdm

    #sudo apt install -y feh   # wallpaper
    if [ -d "$HOME/.config" ]; then 
        mkdir "$HOME/.config"
    fi
    ln -sf /$DOTFILES_DIR/.config/awesome $HOME/.config/awesome

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

    # End Kitty
    #if [ -d "$HOME/.config/awesome" ]; then
	#    rm $HOME/.config/awesome/rc.lua
    #    ln -sf $DOTFILES_DIR/.config/awesome/rc.lua $HOME/.config/awesome/rc.lua
    #fi
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

# set Java
sudo apt install -y default-jdk

nvim
awesome_install
python
update_symlinks

if [ $ZSH = yes ]; then
    zsh_install
fi
