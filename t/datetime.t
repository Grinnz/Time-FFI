use strict;
use warnings;
use Test2::V0;
use Test::Needs 'DateTime';
use Time::FFI::tm;

my $time = time;
my @localtime = CORE::localtime $time;
my @gmtime = CORE::gmtime $time;

my $local_tm = Time::FFI::tm->from_list(@localtime);
my $local_dt = $local_tm->to_object('DateTime', 1);
isa_ok $local_dt, 'DateTime';
is $local_dt, object {
  call second => $local_tm->sec;
  call minute => $local_tm->min;
  call hour   => $local_tm->hour;
  call day    => $local_tm->mday;
  call month  => $local_tm->mon + 1;
  call year   => $local_tm->year + 1900;
  call day_of_week => $local_tm->wday || 7; # Sunday == 7
  call day_of_year => $local_tm->yday + 1;
  call epoch  => $time;
}, 'local DateTime object';
my $local_from = Time::FFI::tm->from_object($local_dt, 1);
is $local_from, object {
  call sec   => $local_tm->sec;
  call min   => $local_tm->min;
  call hour  => $local_tm->hour;
  call mday  => $local_tm->mday;
  call mon   => $local_tm->mon;
  call year  => $local_tm->year;
  call wday  => $local_tm->wday;
  call yday  => $local_tm->yday;
  call isdst => $local_tm->isdst;
}, 'local tm structure from DateTime object';
is $local_from->epoch(1), $time, 'right epoch timestamp from local time';

my $utc_tm = Time::FFI::tm->from_list(@gmtime);
my $utc_dt = $utc_tm->to_object('DateTime', 0);
isa_ok $utc_dt, 'DateTime';
is $utc_dt, object {
  call second => $utc_tm->sec;
  call minute => $utc_tm->min;
  call hour   => $utc_tm->hour;
  call day    => $utc_tm->mday;
  call month  => $utc_tm->mon + 1;
  call year   => $utc_tm->year + 1900;
  call day_of_week => $utc_tm->wday || 7; # Sunday == 7
  call day_of_year => $utc_tm->yday + 1;
  call epoch  => $time;
}, 'UTC DateTime object';
my $utc_from = Time::FFI::tm->from_object($utc_dt, 0);
is $utc_from, object {
  call sec   => $utc_tm->sec;
  call min   => $utc_tm->min;
  call hour  => $utc_tm->hour;
  call mday  => $utc_tm->mday;
  call mon   => $utc_tm->mon;
  call year  => $utc_tm->year;
  call wday  => $utc_tm->wday;
  call yday  => $utc_tm->yday;
  call isdst => $utc_tm->isdst;
}, 'UTC tm structure from DateTime object';
is $utc_from->epoch(0), $time, 'right epoch timestamp from UTC time';

my $dst_tm = Time::FFI::tm->new(
  year => 119,
  mon  => 5,
  mday => 20,
  hour => 5,
  min  => 0,
  sec  => 0,
);
my $dst_dt = $dst_tm->to_object('DateTime', 1);
my $real_dt = DateTime->new(
  year   => 2019,
  month  => 6,
  day    => 20,
  hour   => 5,
  minute => 0,
  second => 0,
  time_zone => 'local',
);
is $dst_dt->epoch, $real_dt->epoch, '(possible) DST interpreted correctly';

done_testing;
