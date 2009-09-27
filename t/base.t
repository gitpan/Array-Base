use warnings;
use strict;

use Test::More tests => 22;

our @t = qw(a b c d e f);
our $r = \@t;
our($i3, $i4, $i8, $i9) = (3, 4, 8, 9);

use Array::Base +3;

is $t[3], "a";
is $t[4], "b";
is $t[8], "f";
is $t[9], undef;
is $r->[3], "a";
is $r->[4], "b";
is $r->[8], "f";
is $r->[9], undef;

is $t[$i3], "a";
is $t[$i4], "b";
is $t[$i8], "f";
is $t[$i9], undef;
is $r->[$i3], "a";
is $r->[$i4], "b";
is $r->[$i8], "f";
is $r->[$i9], undef;

is $#t, 8;
is $#$r, 8;

is_deeply [ @t[3,4,8,9] ], [ qw(a b f), undef ];
is_deeply [ @{$r}[3,4,8,9] ], [ qw(a b f), undef ];

SKIP: {
	skip "no lexical \$_", 2 unless eval q{my $_; 1};
	eval q{
		my $_;
		is_deeply [ @t[3,4,8,9] ], [ qw(a b f), undef ];
		is_deeply [ @{$r}[3,4,8,9] ], [ qw(a b f), undef ];
	};
}

1;
