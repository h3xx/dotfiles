" set path according to perl's @INC variable
" can be updated using:
" # perl -e 'printf "setl path+=%s\n" x @INC, @INC'

"" x86_64 - 5.10.1
setl path+=/usr/lib64/perl5/5.10.1/x86_64-linux-thread-multi
setl path+=/usr/lib64/perl5/5.10.1
setl path+=/usr/lib64/perl5/site_perl/5.10.1/x86_64-linux-thread-multi
setl path+=/usr/lib64/perl5/site_perl/5.10.1
setl path+=/usr/lib64/perl5/site_perl
setl path+=/usr/lib64/perl5/vendor_perl/5.10.1/x86_64-linux-thread-multi
setl path+=/usr/lib64/perl5/vendor_perl/5.10.1
setl path+=/usr/lib64/perl5/vendor_perl

"" i486 - 5.10.0
"setl path+=/usr/lib/perl5/5.10.0/i486-linux-thread-multi
"setl path+=/usr/lib/perl5/5.10.0
"setl path+=/usr/lib/perl5/site_perl/5.10.0/i486-linux-thread-multi
"setl path+=/usr/lib/perl5/site_perl/5.10.0
"setl path+=/usr/lib/perl5/site_perl
"setl path+=/usr/lib/perl5/vendor_perl/5.10.0/i486-linux-thread-multi
"setl path+=/usr/lib/perl5/vendor_perl/5.10.0
"setl path+=/usr/lib/perl5/vendor_perl

" set include pattern (not working)
"setl inc=^\\s*use\\s*\\zs[^\s]+
"setl inex=substitute(v:fname,'::','/','g')
"setl sua+=.pm
