let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
call plug#end()

set number
set laststatus=0
set fillchars=eob:\ 

inoremap <silent> <C-p> <Up>
inoremap <silent> <C-n> <Down>
inoremap <silent> <C-f> <Right>
inoremap <silent> <C-b> <Left>
inoremap <silent> <C-a> <Home>
inoremap <silent> <C-e> <End>
inoremap <silent> <C-h> <BS>
inoremap <silent> <C-d> <Del>
inoremap <silent> <C-k> <C-o>d$
inoremap <C-s> <ESC>:wq<CR>
nnoremap <C-s> :wq<CR>
nnoremap y "+y
vnoremap y "+y
autocmd VimEnter * startinsert

set termguicolors

highlight Normal       ctermbg=NONE guibg=NONE
highlight NormalNC     ctermbg=NONE guibg=NONE
highlight EndOfBuffer  ctermbg=NONE guibg=NONE
highlight SignColumn   ctermbg=NONE guibg=NONE
highlight VertSplit    ctermbg=NONE guibg=NONE
highlight LineNr       ctermbg=NONE guibg=NONE
highlight StatusLine   ctermbg=NONE guibg=NONE
highlight StatusLineNC ctermbg=NONE guibg=NONE
