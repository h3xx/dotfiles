setl spell
setl colorcolumn=52,72
setl nomodeline

nnoremap <buffer> ,R iReference ticket: 
nnoremap <buffer> ,U :normal iUpdate submodule pointers<cr>
nnoremap <buffer> ,G :normal iGrep thru all projects in git reveals no usages.<cr>
" jump to start of buffer
0
