" Do these things only for a windows machine
if has('win32') || has('win64')
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
" open gui maximized
au GUIEnter * simalt ~x
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim Plug
""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
"Plug 'chazy/cscope_maps'
Plug 'simplyzhao/cscope_maps.vim'
Plug 'romainl/Apprentice'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'abudden/taghighlight-automirror'
Plug 'ervandew/supertab'
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Look and Feel
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" turn off the vi compatabilty mode
set nocompatible

" set up the font I want
set gfn=Inconsolata:h14:cANSI

" doublewide command line
set laststatus=2		

" gotta pick a theme
silent! color apprentice

" turn on syntax highlighting
syntax on

" get rid of the toolbar..useless
set guioptions-=T

" no annoying backups
set nobackup nowritebackup

" better bracket support
set showmatch

" better backspacing
set backspace=indent,eol,start

" get rid of message prompt
set shortmess=atI

" show relative line numbering
set rnu 

" When nonempty, this option determines the content of the status line
set statusline=%F%m%r%h%w\ [TYPE=%Y]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]

" share windows clipboard
set clipboard=unnamed

" minimum lines about or below the curser
set scrolloff=10

" enable omni compleation
filetype plugin on
set omnifunc=syntaxcomplete#Complete

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Formatting/Layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" how automatic formatting is to be done
set formatoptions=tcrqn

" take indent for new line from previous line
set autoindent

" smart autoindenting for C programs
set smartindent

" do c-style indenting
set cindent

" tab spacing (settings below are just to unify it)
set tabstop=3

" unify
set softtabstop=3

" unify
set shiftwidth=3

" no tabs please
set expandtab

" do not wrap lines
set nowrap

" use tabs at the start of a line, spaces elsewhere
set smarttab
 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" case insensitive searching unless I add case to search
set ic
set smartcase

" turn on incremental search
set incsearch

" turn on seach highlighting
set hlsearch

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key Remappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" control - hjkl change vim panes
noremap <C-H> <C-W><C-H>
noremap <C-J> <C-W><C-J>
noremap <C-K> <C-W><C-K>
noremap <C-L> <C-W><C-L>

" switch tabs w/ control tab
noremap <C-Tab> <C-PageDown> 
noremap <C-S-Tab> <C-PageUp> 

" create shortcut for opening in tabs
" noremap tb tab ball<CR>

" set up TagList shortcut key
"nnoremap <silent> <F8> :TlistToggle<CR>

" Leader-d inserts current data
inoremap <leader>d <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <leader>f <C-R>=strftime("%H:%M:%S")<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Path rules
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Find tags file
set tags=tags;d:\usr\distrib\

" Find cscope database
let cscopepath=findfile("cscope.out",".;")
if cscopepath != ''
  silent exe 'cs add' cscopepath
endif

" Move swap directory to tmp
if has("win32") || has("win64")
   set directory=$TMP
else
   set directory=/tmp
end 

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax Rules
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" load up organi kon file highlighting if .kon file
au BufNewFile,BufRead *.kon  setf kon

" wiki highlighting
au BufNewFile,BufRead *wiki.vi* setf moin

" A66 assembler files
au BufNewFile,BufRead *.A66 setf pic

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Abbreviations
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CScope Rule
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" remove separators
"let g:airline_left_sep=''
"let g:airline_right_sep=''

