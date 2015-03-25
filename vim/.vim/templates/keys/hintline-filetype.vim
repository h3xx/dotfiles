" insert vim hint line that sets the filetype

" (&commentstring should be printf-compatible, e.g. "#%s")

exe 'norm o'.substitute(printf(&commentstring, ' vi: ft='.&ft), ' \+', ' ', 'g')

" (if it's annoying for vim to get confused about the filetype of *this* file)
"exe 'norm o'.substitute(printf(&commentstring, ' vi'.': ft='.&ft), ' \+', ' ', 'g')
" vi: ft=vim
