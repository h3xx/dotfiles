" header for perl modules

" expand('%:p:h:t'): basename of containing directory
" expand('%:t:r'): basename of current file, one extension removed
:0put =printf('package %s::%s;', expand('%:p:h:t'), expand('%:t:r'))

append
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my $class = shift;

    my $self = bless {
        @_,
    }, $class;

    $self
}

=head1 AUTHOR

Dan Church S<E<lt>h3xx@gmx.comE<gt>>

=head1 COPYRIGHT

Copyright (C) YEAR Dan Church.
.
s/YEAR/\=strftime("%Y")/
append

License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

=cut

1;
.
