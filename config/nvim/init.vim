set number

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
