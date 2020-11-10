" common key combinations

" ,g - insert getopts processing block
nnoremap <buffer> <silent> ,g :ru templates/keys/sh-getopts.vim<CR>

" ,t - insert call to mktemp(1)
nnoremap <buffer> <silent> ,t :ru templates/keys/sh-mktemp.vim<CR>

" ,T - insert shell-script cleanup code that uses trap
nnoremap <buffer> <silent> ,T :ru templates/keys/sh-trap-cleanup.vim<CR>

" ,Z - insert HELP_MESSAGE function
nnoremap <buffer> <silent> ,Z :ru templates/keys/sh-help_message.vim<CR>
