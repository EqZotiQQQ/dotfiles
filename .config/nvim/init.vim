let config_path = expand('~/.config/nvim')
exec 'source '.config_path.'/plugins.vim'

"----------------- Settings ------------------
filetype plugin indent on

" Enable external rc files
set exrc
set secure

set notimeout
set ttimeout

set mouse=a

set number
set cursorline

set noshowmode

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set nowrap linebreak

set list listchars=tab:→\ ,trail:·,nbsp:␣,extends:⟩,precedes:⟨

set inccommand=split
set incsearch

set ignorecase
set smartcase

set autoread
set virtualedit=block
set hidden

set wildmenu
set wildmode=longest,list:full

set termguicolors

set conceallevel=2
set concealcursor=n

set splitright
set nosplitbelow

set completeopt=noinsert,menuone,noselect
set shortmess+=c

set diffopt+=vertical
set tags=./.tags;
set foldlevel=99

syntax on

" ------------------ Colorscheme ------------------
set background=dark
colorscheme gruvbox
call gruvbox#hls_hide()
