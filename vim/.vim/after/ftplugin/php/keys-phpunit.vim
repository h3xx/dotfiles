" common key combinations for PHPUnit tests

if expand("%:t") !~ 'Test.php'
	finish
endif

nnoremap <buffer> <silent> ,M :ru templates/keys/phpunit-M.vim<CR>
nnoremap <buffer> <silent> ,P :ru templates/keys/phpunit-P.vim<CR>
nnoremap <buffer> <silent> ,K :ru templates/keys/phpunit-K.vim<CR>
nnoremap <buffer> <silent> ,d :ru templates/keys/phpunit-d.vim<CR>
