# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v6.022.
use strict;
use warnings;

use 5.008001;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "libffi interface to POSIX date and time functions",
  "AUTHOR" => "Dan Book <dbook\@cpan.org>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "Time-FFI",
  "LICENSE" => "artistic_2",
  "MIN_PERL_VERSION" => "5.008001",
  "NAME" => "Time::FFI",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Exporter" => "5.57",
    "FFI::Platypus" => "1.00",
    "Module::Runtime" => 0,
    "Time::Local" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "Test2::V0" => 0,
    "Test::More" => 0,
    "Test::Needs" => 0
  },
  "VERSION" => "2.002",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Exporter" => "5.57",
  "ExtUtils::MakeMaker" => 0,
  "FFI::Platypus" => "1.00",
  "File::Spec" => 0,
  "Module::Runtime" => 0,
  "Test2::V0" => 0,
  "Test::More" => 0,
  "Test::Needs" => 0,
  "Time::Local" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
