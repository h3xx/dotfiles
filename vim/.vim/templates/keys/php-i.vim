" surround inline control block with curly braces

" e.g.:
"
" if ($f_o)
"     $var = 'x';
"
" Transform into:
"
" if ($f_o) {
"     $var = 'x';
" }

exe "norm A {\<C-o>j\<C-o>o}\<Esc>"
