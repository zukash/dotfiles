call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
call plug#end()

set number
set laststatus=0

inoremap <silent> <C-p> <Up>
inoremap <silent> <C-n> <Down>
inoremap <silent> <C-f> <Right>
inoremap <silent> <C-b> <Left>
inoremap <silent> <C-a> <Home>
inoremap <silent> <C-e> <End>
inoremap <silent> <C-h> <BS>
inoremap <silent> <C-d> <Del>
inoremap <silent> <C-k> <C-o>d$
inoremap <C-q> <ESC>:wq<CR>
nnoremap <C-q> :wq<CR>
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
