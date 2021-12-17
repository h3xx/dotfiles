" common key combinations

" ,a - insert ask_yn function
nnoremap <buffer> <silent> ,a :ru templates/keys/sh-ask_yn.vim<CR>

" ,b - insert in-bash basename
nnoremap <buffer> <silent> ,b :ru templates/keys/sh-basename.vim<CR>

" ,d - insert in-bash basename
nnoremap <buffer> <silent> ,d :ru templates/keys/sh-dirname.vim<CR>

" ,g - insert getopts processing block
nnoremap <buffer> <silent> ,g :ru templates/keys/sh-getopts.vim<CR>

" ,G - insert long option processing block
nnoremap <buffer> <silent> ,G :ru templates/keys/sh-getopt-long.vim<CR>

" ,h - insert file header
nnoremap <buffer> <silent> ,h :ru templates/headers/sh.vim<CR>

" ,s - insert in-bash suffix strip
nnoremap <buffer> <silent> ,s :ru templates/keys/sh-strip-suffix.vim<CR>

" ,t - insert call to mktemp(1)
nnoremap <buffer> <silent> ,t :ru templates/keys/sh-mktemp.vim<CR>

" ,T - insert shell-script cleanup code that uses trap
nnoremap <buffer> <silent> ,T :ru templates/keys/sh-trap-cleanup.vim<CR>

" ,w - insert in-bash WORKDIR set
nnoremap <buffer> <silent> ,w :ru templates/keys/sh-workdir.vim<CR>

" ,Z - insert HELP_MESSAGE function
nnoremap <buffer> <silent> ,Z :ru templates/keys/sh-help_message.vim<CR>
