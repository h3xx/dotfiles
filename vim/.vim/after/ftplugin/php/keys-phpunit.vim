" common key combinations for PHPUnit tests

if expand("%:t") !~ 'Test.php'
	finish
endif

nnoremap <buffer> <silent> ,M :so ~/.vim/templates/keys/phpunit-M.vim<CR>
nnoremap <buffer> <silent> ,P :so ~/.vim/templates/keys/phpunit-P.vim<CR>
nnoremap <buffer> <silent> ,K :so ~/.vim/templates/keys/phpunit-K.vim<CR>
nnoremap <buffer> <silent> ,d :so ~/.vim/templates/keys/phpunit-d.vim<CR>
