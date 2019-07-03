package Time::FFI::tm;

use strict;
use warnings;
use FFI::Platypus::Record;

our $VERSION = '0.001';

my @tm_members = qw(tm_sec tm_min tm_hour tm_mday tm_mon tm_year tm_wday tm_yday tm_isdst);

record_layout(
  (map { (int => $_) } @tm_members),
  'long'      => 'tm_gmtoff',
  'string ro' => 'tm_zone',
);

sub from_list {
  my ($class, @args) = @_;
  my %attr;
  $attr{$tm_members[$_]} = $args[$_] for 0..$#tm_members;
  return $class->new(\%attr);
}

sub to_list {
  my ($self) = @_;
  return map { $self->$_ } @tm_members;
}

1;

=head1 NAME

Time::FFI::tm - POSIX tm structure

=head1 SYNOPSIS

  use Time::FFI::tm;

  my $tm = Time::FFI::tm->new(
    tm_year => 95, # years since 1900
    tm_mon  => 0,  # 0 == January
    tm_mday => 1,
    tm_hour => 13,
    tm_min  => 25,
    tm_sec  => 59,
  );

  my $tm = Time::FFI::tm->from_list(localtime(time));

  my $epoch = POSIX::mktime($tm->to_list);

=head1 DESCRIPTION

This L<FFI::Platypus::Record> class represents a time structure as used by
functions such as L<mktime(3)> and L<strptime(3)>.

=head1 ATTRIBUTES

=head2 tm_sec

=head2 tm_min

=head2 tm_hour

=head2 tm_mday

=head2 tm_mon

=head2 tm_year

=head2 tm_wday

=head2 tm_yday

=head2 tm_isdst

=head2 tm_gmtoff

=head2 tm_zone

The integer components of the C<tm> struct are stored as settable attributes.
The C<tm_zone> attribute is read-only.

=head1 METHODS

=head2 new

  my $tm = Time::FFI::tm->new;
  my $tm = Time::FFI::tm->new(tm_year => $year, ...);
  my $tm = Time::FFI::tm->new({tm_year => $year, ...});

Construct a new B<Time::FFI::tm> object representing a C<tm> struct.

=head2 from_list

  my $tm = Time::FFI::tm->from_list($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);

Construct a new B<Time::FFI::tm> object from the passed list of values, in the
same order returned by L<perlfunc/localtime>.

=head2 to_list

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = $tm->to_list;

Return the list of values in the structure, in the same order returned by
L<perlfunc/localtime>.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Time::FFI>
