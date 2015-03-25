" header for perl CGI scripts

insert
#!/usr/bin/perl -w
use strict;

#use CGI::Carp 'fatalsToBrowser';
require CGI::Simple;
require CGI::Session;

my $cgi = CGI::Simple->new;
my $session = CGI::Session->new(undef, $cgi, undef);

if ($cgi->http or $cgi->https) {
	print $cgi->header(
		'-type'		=> 'text/html',
		'-charset'	=> 'utf8',
		'-cookie'	=> $session->cookie,
	);
}

.
