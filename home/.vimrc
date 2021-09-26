"------------------ Settings ------------------



set number  "show number of line

"------------------ Tabs ----------------------

set tabstop=4  "tab size"
set shiftwidth=4
set smarttab
set expandtab  "switches tabs to same quantity of spaces"

"------------------ Search --------------------

set hlsearch "Highlight search result
set ignorecase
set smartcase 


"------------------ Other ---------------------

syntax on

" ------------------ Colorscheme --------------

"TODO include any scheme 


"-------------------   Plugins   --------------
"https://medium.com/@huntie/10-essential-vim-plugins-for-2018-39957190b7a9

call plug#begin('~/.vim/plugged')
"FZF: https://github.com/junegunn/fzf.vim

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

"light line htps://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

Plug 'vim-airline/vim-airline-themes'

call plug#end()


let g:airline_theme='simple'



map <F4> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
