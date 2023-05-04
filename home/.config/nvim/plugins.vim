" autoinstall vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.config/nvim/plugins/')

Plug 'vim-airline/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdTree'

Plug 'rktjmp/highlight-current-n.nvim'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
" ------------------ Colorscheme ------------------

Plug 'dkasak/gruvbox'

call plug#end()


let g:gruvbox_bold = 1
let g:gruvbox_italic = 1
let g:gruvbox_invert_selection = 0
let g:gruvbox_italicize_strings = 1
