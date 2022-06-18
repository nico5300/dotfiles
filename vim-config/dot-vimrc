" filetype plugin indent on

" Plugins:

call plug#begin('~/.config/nvim/plugged')

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'gruvbox-community/gruvbox'
    Plug 'vim-airline/vim-airline'
inoremap <S-Tab> <esc>la
call plug#end()


syntax on
set ai                             "autoindent
set ignorecase smartcase           "ignore case, except if contains uppercase
set incsearch
set hlsearch                       "highlight search results
set showmatch                      "matching parentheses
set wildmenu                       "visual autocomplete for command menu
set endofline                      "make sure last line ends with \n
set scrolloff=6                    "lines to keep visible when scrolling
set noerrorbells
set nowrap
set signcolumn
set tabstop=4
set shiftwidth=4
set expandtab
set number
set relativenumber




" <Esc><Esc> redraws the screen and removes any search highlighting.
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>


" Shift Tab jumps one character to the left without leaving insert mode
inoremap <C-Tab> <Esc>la

colorscheme gruvbox
highlight Normal guibg=none
let g:gruvbox_transparent_bg=1


"config for coc:
set pumheight=7

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

