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
        -c|--compton)
            COMPTON=yes
            shift
            ;;
        *)
    esac
done

function zsh_install {
    echo "###### installing zsh #######"
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
    exit 0
}

#its under testings. If it wont work do it by ur hands
function compton {
    echo "###### isntalling compton #######"
    mkdir -p $HOME/git/other
    git clone https://github.com/tryone144/compton.git $HOME/git/other
    make -C $HOME/git/other/compton
    make docks -C $HOME/git/other/compton
    make install -C $HOME/git/other/compton
    #https://www.reddit.com/r/voidlinux/comments/capd59/how_do_i_install_compton_fork_tryone144/
    ln -sf $DOTFILES_DIR/.config/compton.conf $HOME/.config/compton.conf
    echo "###### compton installed ########"
    exit 0
}

if [ $ZSH = yes ]; then
    zsh_install
fi

if [ $COMPTON = yes ]; then 
    compton
fi

sudo apt upgrade -y
sudo apt install -y curl htop openssh-server gcc make cmake clang 

echo "###### installing neovim ... ######"
sudo apt install nvim
mkdir $HOME/.config/nvim
ln -sf $DOTFILES_DIR/.config/nvim/autocmd.vim $HOME/.config/nvim/autocmd.vim
ln -sf $DOTFILES_DIR/.config/nvim/bindings.vim $HOME/.config/nvim/bindings.vim
ln -sf $DOTFILES_DIR/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
ln -sf $DOTFILES_DIR/.config/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $DOTFILES_DIR/.config/nvim/plugins.vim $HOME/.config/nvim/plugins.vim
echo "###### installation done #######"

echo "###### installing git... #######"
sudo apt install -y git
git config --global merge.tool vimdiff
git config --global user.name "Mikhail Fedyakov"
git config --global user.email mf_52@mail.ru
git config --global core.editor "vim"
# git config credential.helper store
echo "###### installation done #######"


echo "###### installing awesome ... #######"
sudo apt install -y awesome-extra feh #lightdm
mkdir $HOME/.config/awesome
cp /etc/xdg/awesome $HOME/.config/awesome
ln -sf /$DOTFILES_DIR/.config/awesome $HOME/.config/awesome
ln -sf /$DOTFILES_DIR/.xinitrc $HOME/.xinitrc


echo "###### installing kitty ... ######"
# under testing 
sudo apt install -y kitty

#cd ~
#curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

#if [ ! -d "$HOME/.local/bin" ]; then
#    mkdir -p "$HOME/.local/bin"
#fi

#if [ ! -d "$HOME/.local/lib" ]; then 
#    mkdir -p "$HOME/.local/lib"
#fi

#cp -rf $HOME/.local/kitty.app/share/* $HOME/.local/share/
#cp -rf $HOME/.local/kitty.app/bin/* $HOME/.local/bin/
#cp -rf $HOME/.local/kitty.app/lib/* $HOME/.local/lib/

#export PATH=$PATH:$HOME/.local/bin

#ln -sf $DOTFILES_DIR/.config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

echo "###### setting fonts for Kitty term ######"
cd ~
ln -sf $DOTFILES_DIR/.fonts $HOME/.fonts 
cd .fonts 
fc-cache -fv 
cd ~
echo "####### AwesomeWM and Kitty term installed"

ln -sf $DOTFILES_DIR/Wallpaper $HOME/Pictures
ln -sf $DOTFILES_DIR/.profile $HOME/.profile
ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc
ln -sf $DOTFILES_DIR/.bash_profile $HOME/.bash_profile

sudo apt install -y python3
sudo apt install -y python3-pip
sudo apt install -y default-jdk
