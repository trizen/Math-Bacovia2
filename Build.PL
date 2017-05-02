#!/usr/bin/perl

use utf8;
use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
     module_name        => 'Math::Bacovia',
     license            => 'artistic_2',
     dist_author        => q{Daniel Șuteu <trizenx@gmail.com>},
     dist_version_from  => 'lib/Math/Bacovia.pm',
     release_status     => 'stable',
     configure_requires => {
                            'Module::Build' => 0,
                           },
     build_requires => {
                        'Test::More' => 0,
                       },
     requires => {
                  'perl'                => 5.014,
                  'Math::AnyNum'        => 0.01,
                  'List::UtilsBy::XS'   => 0,
                  'Class::Multimethods' => 1.70,
                 },
     add_to_cleanup     => ['Math-Bacovia-*'],
     create_makefile_pl => 'traditional',
);

$builder->create_build_script();