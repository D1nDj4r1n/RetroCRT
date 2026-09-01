" Vim is the lightweight editor; Neovim remains the IDE.
set nocompatible
filetype plugin indent on
syntax enable

set termguicolors
set background=dark
colorscheme retrocrt

set number
set relativenumber
set cursorline
set hidden
set wildmenu
set showmatch
set incsearch
set hlsearch
set ignorecase
set smartcase
set splitbelow
set splitright

if has('clipboard')
  set clipboard=unnamedplus
endif

let mapleader = ' '
nnoremap <silent> <leader>e :Lexplore<CR>

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_winsize = 25

function! RetrocrtStatusline() abort
  let l:mode = mode()
  if l:mode =~# '^i'
    let l:group = 'RetroStatusInsert'
    let l:label = ' INSERT '
  elseif l:mode =~# '^[vV\x16]'
    let l:group = 'RetroStatusVisual'
    let l:label = ' VISUAL '
  else
    let l:group = 'RetroStatusNormal'
    let l:label = ' NORMAL '
  endif
  return '%#' . l:group . '#' . l:label
        \ . '%#StatusLine# %f %m%r%='
        \ . '%y  %l:%c  %p%% '
endfunction

set statusline=%!RetrocrtStatusline()
set laststatus=2
