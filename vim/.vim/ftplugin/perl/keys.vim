" header command
if expand("%:e") == 'pm'
	" ,h - insert header text
	nnoremap <buffer> <silent> ,h :ru templates/headers/perl-pm.vim<CR>
elseif expand("%:e") == 'cgi'
	nnoremap <buffer> <silent> ,h :ru templates/headers/perl-cgi.vim<CR>
else
	nnoremap <buffer> <silent> ,h :ru templates/headers/perl.vim<CR>
endif

" common key combinations

" ,d - insert Data::Dumper call
nnoremap <buffer> <silent> ,d :ru templates/keys/perl-data-dumper.vim<CR>

" ,g - insert Getopt::Std option processing
nnoremap <buffer> <silent> ,g :ru templates/keys/perl-getopts.vim<CR>

" ,s - insert file handle slurp
nnoremap <buffer> <silent> ,s :ru templates/keys/perl-slurp.vim<CR>
