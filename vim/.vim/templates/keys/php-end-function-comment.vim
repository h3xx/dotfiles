" put " // end <FUNCTION>()" at the end of the current function's end brace

" [m = jump to start of method before cursor
" ]M = jump to end of method after cursor
exe "norm j[[t(yiw]Ma // end \<C-r>\"()"
