" common key combinations for PHPUnit tests

if expand("%:t") !~ 'Test.php'
	finish
endif

nnoremap <buffer> <silent> ,M :ru templates/keys/phpunit-reflect-method.vim<CR>
nnoremap <buffer> <silent> ,P :ru templates/keys/phpunit-reflect-property.vim<CR>
nnoremap <buffer> <silent> ,K :ru templates/keys/phpunit-mock-object.vim<CR>
nnoremap <buffer> <silent> ,d :ru templates/keys/phpunit-assert-dataset-equals.vim<CR>
