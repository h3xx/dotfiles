" set path according to perl's @INC variable
" can be updated using:
" # perl -e 'printf "setl path+=%s\n" x @INC, @INC'

" x86_64
setl path+=/usr/lib64/perl5/vendor_perl
setl path+=/usr/share/perl5/vendor_perl
setl path+=/usr/lib64/perl5
setl path+=/usr/share/perl5

" i486
"setl path+=/usr/lib/perl5/vendor_perl
"setl path+=/usr/share/perl5/vendor_perl
"setl path+=/usr/lib/perl5
"setl path+=/usr/share/perl5

" set include pattern (not working)
"setl inc=^\\s*use\\s*\\zs[^\s]+
"setl inex=substitute(v:fname,'::','/','g')
"setl sua+=.pm
