package Time::FFI::tm;

use strict;
use warnings;
use Carp ();
use FFI::Platypus::Record ();
use Module::Runtime ();
use Time::Local ();

our $VERSION = '1.005';

my @tm_members = qw(sec min hour mday mon year wday yday isdst);

FFI::Platypus::Record::record_layout(
  (map { (int => $_) } @tm_members),
  long   => 'gmtoff',
  string => 'zone',
);

{
  no strict 'refs';
  *{"tm_$_"} = \&$_ for @tm_members, 'gmtoff', 'zone';
}

sub from_list {
  my ($class, @args) = @_;
  my %attr = map { ($tm_members[$_] => $args[$_]) } 0..$#tm_members;
  return $class->new(\%attr);
}

sub from_object {
  my ($class, $obj, $islocal) = @_;
  if ($obj->isa('Time::FFI::tm') or $obj->isa('Time::tm')) {
    my %attr = map { ($_ => $obj->$_) } qw(sec min hour mday mon year wday yday isdst);
    return $class->new(\%attr);
  } elsif ($obj->can('epoch')) {
    require Time::FFI;
    return $islocal ? Time::FFI::localtime($obj->epoch) : Time::FFI::gmtime($obj->epoch);
  } else {
    my $class = ref $obj;
    Carp::croak "Cannot convert from unrecognized object class $class";
  }
}

sub to_list {
  my ($self) = @_;
  return map { $self->$_ } @tm_members;
}

sub to_object {
  my ($self, $class, $islocal) = @_;
  Module::Runtime::require_module $class;
  if ($class->isa('Time::Piece')) {
    my ($epoch, $new) = $self->_mktime($islocal);
    return $islocal ? scalar $class->localtime($epoch) : scalar $class->gmtime($epoch);
  } elsif ($class->isa('Time::Moment')) {
    my ($epoch, $new) = $self->_mktime($islocal);
    my $moment = $class->new(
      year   => $new->year + 1900,
      month  => $new->mon + 1,
      day    => $new->mday,
      hour   => $new->hour,
      minute => $new->min,
      second => $new->sec,
    );
    return $islocal ? $moment->with_offset_same_local(($moment->epoch - $epoch) / 60) : $moment;
  } elsif ($class->isa('DateTime')) {
    my ($epoch, $new) = $self->_mktime($islocal);
    return $class->new(
      year   => $new->year + 1900,
      month  => $new->mon + 1,
      day    => $new->mday,
      hour   => $new->hour,
      minute => $new->min,
      second => $new->sec,
      time_zone => $islocal ? 'local' : 'UTC',
    );
  } elsif ($class->isa('Time::FFI::tm') or $class->isa('Time::tm')) {
    my %attr = map { ($_ => $self->$_) } qw(sec min hour mday mon year wday yday isdst);
    return $class->new(%attr);
  } else {
    Carp::croak "Cannot convert to unrecognized object class $class";
  }
}

sub epoch {
  my ($self, $islocal) = @_;
  my ($epoch, $new) = $self->_mktime($islocal);
  return $epoch;
}

sub normalized {
  my ($self, $islocal) = @_;
  my ($epoch, $new) = $self->_mktime($islocal);
  if ($islocal) {
    return $new;
  } else {
    require Time::FFI;
    return Time::FFI::gmtime($epoch);
  }
}
*with_extra = \&normalized;

sub _mktime {
  my ($self, $islocal) = @_;
  if ($islocal) {
    require Time::FFI;
    my %attr = map { ($_ => $self->$_) } qw(sec min hour mday mon year);
    $attr{isdst} = -1;
    my $new = (ref $self)->new(\%attr);
    return (Time::FFI::mktime($new), $new);
  } else {
    my $year = $self->year;
    $year += 1900 if $year >= 0; # avoid timegm year heuristic
    my @vals = ((map { $self->$_ } qw(sec min hour mday mon)), $year);
    return (scalar Time::Local::timegm(@vals), $self);
  }
}

1;

=head1 NAME

Time::FFI::tm - POSIX tm record structure

=head1 SYNOPSIS

  use Time::FFI::tm;

  my $tm = Time::FFI::tm->new(
    year  => 95, # years since 1900
    mon   => 0,  # 0 == January
    mday  => 1,
    hour  => 13,
    min   => 25,
    sec   => 59,
    isdst => -1, # allow DST status to be determined by the system
  );
  $tm->mday($tm->mday + 1); # add a day

  my $in_local = $tm->normalized(1);
  say $in_local->isdst; # now knows if DST is active

  my $tm = Time::FFI::tm->from_list(CORE::localtime(time));

  my $epoch = POSIX::mktime($tm->to_list);
  my $epoch = $tm->epoch(1);

  my $tm = Time::FFI::tm->from_object(Time::Moment->now, 1);
  my $datetime = $tm->to_object('DateTime', 1);

=head1 DESCRIPTION

This L<FFI::Platypus::Record> class represents the C<tm> struct defined by
F<time.h> and used by functions such as L<mktime(3)> and L<strptime(3)>. This
is used by L<Time::FFI> to provide access to such structures.

The structure does not store an explicit time zone, so you must specify whether
to interpret it as local or UTC time whenever rendering it to or from an actual
date/time.

=head1 ATTRIBUTES

The integer components of the C<tm> struct are stored as settable attributes
that default to 0.

Note that 0 is out of the standard range for the C<mday> value (often
indicating the last day of the previous month), and C<isdst> should be set to a
negative value if unknown, so these values should always be specified
explicitly.

Each attribute also has a corresponding alias starting with C<tm_> to match the
standard C<tm> struct member names.

=head2 sec

Seconds [0,60].

=head2 min

Minutes [0,59].

=head2 hour

Hour [0,23].

=head2 mday

Day of month [1,31].

=head2 mon

Month of year [0,11].

=head2 year

Years since 1900.

=head2 wday

Day of week [0,6] (Sunday =0).

=head2 yday

Day of year [0,365].

=head2 isdst

Daylight Savings flag. (0: off, positive: on, negative: unknown)

=head2 gmtoff

Seconds east of UTC. (May not be available on all systems)

=head2 zone

Timezone abbreviation. (Read only string, may not be available on all systems)

=head1 METHODS

=head2 new

  my $tm = Time::FFI::tm->new;
  my $tm = Time::FFI::tm->new(year => $year, ...);
  my $tm = Time::FFI::tm->new({year => $year, ...});

Construct a new B<Time::FFI::tm> object representing a C<tm> struct.

=head2 from_list

  my $tm = Time::FFI::tm->from_list($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);

Construct a new B<Time::FFI::tm> object from the passed list of values, in the
same order returned by L<perlfunc/localtime>. Missing or undefined values will
be interpreted as the default of 0, but see L</ATTRIBUTES>.

=head2 from_object

  my $tm = Time::FFI::tm->from_object($obj, $islocal);

I<Since version 1.001>

Construct a new B<Time::FFI::tm> object from the passed datetime object, which
may be any object that implements an C<epoch> method returning the Unix epoch
timestamp. If a true value is passed as the second argument, the resulting
structure will represent the local time at that instant; otherwise it will
represent UTC. The original time zone and any fractional seconds will not be
represented in the resulting structure.

A L<Time::tm> or L<Time::FFI::tm> record is also accepted, in which case the
C<$islocal> argument is ignored and the record's values are copied.

=head2 to_list

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = $tm->to_list;

Return the list of values in the structure, in the same order returned by
L<perlfunc/localtime>.

=head2 to_object

  my $piece    = $tm->to_object('Time::Piece', $islocal);
  my $moment   = $tm->to_object('Time::Moment', $islocal);
  my $datetime = $tm->to_object('DateTime', $islocal);

Return an object of the specified class. If a true value is passed as the
second argument, the object will represent the time as interpreted in the local
time zone; otherwise it will be interpreted as UTC. Currently L<Time::Piece>,
L<Time::Moment>, and L<DateTime> (or subclasses) are recognized.

You may also specify L<Time::tm> or L<Time::FFI::tm>, in which case the
C<$islocal> parameter is ignored and the values are copied to a new record.

When interpreted as a local time, values outside the standard ranges are
accepted; this is not currently supported for UTC times.

=head2 epoch

  my $epoch = $tm->epoch($islocal);

I<Since version 1.000>

Translate the time structure into a Unix epoch timestamp (seconds since
1970-01-01 UTC). If a true value is passed, the timestamp will represent the
time as interpreted in the local time zone; otherwise it will be interpreted as
UTC.

When interpreted as a local time, values outside the standard ranges are
accepted; this is not currently supported for UTC times.

=head2 normalized

  my $new = $tm->normalized($islocal);

I<Since version 1.003>

Return a new B<Time::FFI::tm> object representing the same time, but with
C<wday>, C<yday>, C<isdst>, and (if supported) C<gmtoff> and C<zone> set
appropriately. If a true value is passed, these values will be set according to
the time as interpreted in the local time zone; otherwise they will be set
according to the time as interpreted in UTC. Note that this does not replace
the need to pass C<$islocal> for future conversions.

When interpreted as a local time, values outside the standard ranges will also
be normalized; this is not currently supported for UTC times.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Time::FFI>, L<Time::tm>

=for Pod::Coverage with_extra
