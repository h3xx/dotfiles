" build scripts
au BufNewFile,BufRead	*/_configure/*,*/build/scripts/*
			\ setf sh

au BufNewFile,BufRead	*/bin/*
			\ setf sh

" (this happens automatically)
"			\ if &ft == "" |
"			\	setf sh |
"			\ endif
