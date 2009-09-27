=head1 NAME

Array::Base - array index offseting

=head1 SYNOPSIS

	use Array::Base +1;

	no Array::Base;

=head1 DESCRIPTION

This module implements automatic offsetting of array indices.  In normal
Perl, the first element of an array has index 0, the second element has
index 1, and so on.  This module allows array indexes to start at some
other value.  Most commonly it is used to give the first element of an
array the index 1 (and the second 2, and so on), to imitate the indexing
behaviour of FORTRAN and many other languages.  It is usually considered
poor style to do this.

The array index offset is controlled at compile time, in a
lexically-scoped manner.  Each block of code, therefore, is subject to
a fixed offset.  It is expected that the affected code is written with
knowledge of what that offset is.

An array index offset is set up by a C<use Array::Base> directive, with
the desired offset specified as an argument.  Beware that a bare, unsigned
number in that argument position, such as "C<use Array::Base 1>", will
be interpreted as a version number to require of C<Array::Base>.  It is
therefore necessary to give the offset a leading sign, or parenthesise
it, or otherwise decorate it.  The offset may be any integer (positive,
zero, or negative) within the range of Perl's integer arithmetic.

An array index offset declaration is in effect from immediately after the
C<use> line, until the end of the enclosing block or until overridden
by another array index offset declaration.  A declared offset always
replaces the previous offset: they do not add.  "C<no Array::Base>" is
equivalent to "C<use Array::Base +0>": it returns to the Perlish state
with zero offset.

A declared array index offset mainly influences array indexing, both
for single elements and for array slices.  It also affects the value
returned by "C<$#array>": this returns the index of the last element
of the array, taking the offset into account.  Only forwards indexing,
relative to the start of the array, is handled.  End-relative indexing,
normally done using negative index values, is not supported when an
index offset is in effect, and will have unpredictable results.

This module is a replacement for the historical L<C<$[>|perlvar/$[>
variable.  In early Perl that variable was a runtime global, affecting
all array indexing in the program.  In Perl 5, assignment to C<$[>
acts as a lexically-scoped pragma.  C<$[> is highly deprecated, and
the mechanism that supports it is likely to be removed in Perl 5.12.
This module reimplements the index offset feature without using the
deprecated mechanism.  Unlike C<$[>, this module does not affect indexing
into strings with L<index|perlfunc/index> or L<substr|perlfunc/substr>.
It also does not show the offset value in C<$[>.

=cut

package Array::Base;

use warnings;
use strict;

use Lexical::SealRequireHints 0.001;

our $VERSION = "0.000";

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

=head1 PACKAGE METHODS

These methods are meant to be invoked on the C<Array::Base> package.

=over

=item Array::Base->import(BASE)

Sets up an array index offset of I<BASE>, in the lexical environment
that is currently compiling.

=item Array::Base->unimport

Clears the array index offset, in the lexical environment that is
currently compiling.

=back

=head1 SEE ALSO

L<perlvar/$[>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

=head1 COPYRIGHT

Copyright (C) 2009 Andrew Main (Zefram) <zefram@fysh.org>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
