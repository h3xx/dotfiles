" common key combinations

" ,h - insert <?php header in php files
nnoremap <buffer> <silent> ,h :so ~/.vim/templates/keys/php-h.vim<CR>

" ,E - throw new Exception
nnoremap <buffer> <silent> ,E :so ~/.vim/templates/keys/php-E.vim<CR>

" ,c - insert filename (without .php), useful for class files
nnoremap <buffer> <silent> ,c :so ~/.vim/templates/keys/php-c.vim<CR>

" ,D - insert function deprecation warning
nnoremap <buffer> <silent> ,D :so ~/.vim/templates/keys/php-D.vim<CR>
" ,Ctrl-D - insert class deprecation warning
nnoremap <buffer> <silent> ,<C-d> :so ~/.vim/templates/keys/php-c-D.vim<CR>

" ,l - convert inline block to curly-braced block
nnoremap <buffer> <silent> ,l :so ~/.vim/templates/keys/php-l.vim<CR>

" Q - surround current line with ' for insertion into array
nmap <buffer> <silent> Q ysil'A,<Esc>
