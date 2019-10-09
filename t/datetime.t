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
  call second => $local_tm->tm_sec;
  call minute => $local_tm->tm_min;
  call hour   => $local_tm->tm_hour;
  call day    => $local_tm->tm_mday;
  call month  => $local_tm->tm_mon + 1;
  call year   => $local_tm->tm_year + 1900;
  call day_of_week => $local_tm->tm_wday || 7; # Sunday == 7
  call day_of_year => $local_tm->tm_yday + 1;
  call epoch  => $time;
}, 'local DateTime object';

my $utc_tm = Time::FFI::tm->from_list(@gmtime);
my $utc_dt = $utc_tm->to_object('DateTime', 0);
isa_ok $utc_dt, 'DateTime';
is $utc_dt, object {
  call second => $utc_tm->tm_sec;
  call minute => $utc_tm->tm_min;
  call hour   => $utc_tm->tm_hour;
  call day    => $utc_tm->tm_mday;
  call month  => $utc_tm->tm_mon + 1;
  call year   => $utc_tm->tm_year + 1900;
  call day_of_week => $utc_tm->tm_wday || 7; # Sunday == 7
  call day_of_year => $utc_tm->tm_yday + 1;
  call epoch  => $time;
}, 'UTC DateTime object';

my $dst_tm = Time::FFI::tm->new(
  tm_year => 119,
  tm_mon  => 5,
  tm_mday => 20,
  tm_hour => 5,
  tm_min  => 0,
  tm_sec  => 0,
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
