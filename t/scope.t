use warnings;
use strict;

use Test::More tests => 9;

our @t = qw(a b c d e f);

is $t[3], "d";
use Array::Base +3;
is $t[3], "a";
{
	is $t[3], "a";
	use Array::Base -1;
	is $t[3], "e";
	use Array::Base +0;
	is $t[3], "d";
	use Array::Base +1;
	is $t[3], "c";
	no Array::Base;
	is $t[3], "d";
}
is $t[3], "a";
use t::scope_0;
is scope0_test(), "d";

1;
