" common key combinations

" ,a - replace long array with short
nnoremap <buffer> <silent> ,a :ru templates/keys/php-replace_array.vim<CR>

" ,h - insert <?php header in php files
nnoremap <buffer> <silent> ,h :ru templates/keys/php-h.vim<CR>

" ,E - throw new Exception
nnoremap <buffer> <silent> ,E :ru templates/keys/php-E.vim<CR>

" ,c - insert filename (without .php), useful for class files
nnoremap <buffer> <silent> ,c :ru templates/keys/php-c.vim<CR>

" ,D - insert function deprecation warning
nnoremap <buffer> <silent> ,D :ru templates/keys/php-D.vim<CR>
" ,Ctrl-D - insert class deprecation warning
nnoremap <buffer> <silent> ,<C-d> :ru templates/keys/php-c-D.vim<CR>

" ,e - put " // end <FUNCTION>()" at the end of the current function's end
" brace
nnoremap <buffer> <silent> ,e :ru templates/keys/php-e.vim<CR>

" ,l - convert inline block to curly-braced block
nnoremap <buffer> <silent> ,l :ru templates/keys/php-l.vim<CR>

" Q - surround current line with ' for insertion into array
nmap <buffer> <silent> Q ysil'A,<Esc>

" ,t - temporary file creation
nnoremap <buffer> <silent> ,t :ru templates/keys/php-t.vim<CR>
