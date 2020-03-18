" Replace array() => [ ]

" basically,
" put in `array( * )`
" this will magically convert it to [ ]
" this macro is honey badger. it doen't care
exe "norm! ?\\<array(\<CR>f(\<Esc>%r]\<C-o>ncf([\<Esc>"
