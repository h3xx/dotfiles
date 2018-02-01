" common key combinations

" ,g - insert getopts processing block
nnoremap <buffer> <silent> ,g :so ~/.vim/templates/keys/sh-getopts.vim<CR>

" ,Z - insert HELP_MESSAGE function
nnoremap <buffer> <silent> ,Z :so ~/.vim/templates/keys/sh-help_message.vim<CR>

" ,t - insert call to mktemp(1)
nnoremap <buffer> <silent> ,t :so ~/.vim/templates/keys/sh-mktemp.vim<CR>

" ,T - insert shell-script cleanup code that uses trap
nnoremap <buffer> <silent> ,T :so ~/.vim/templates/keys/sh-trap-cleanup.vim<CR>