use 5.006;
use strict;
use warnings;
use Module::Build;
my $builder = Module::Build->new(
    module_name       => 'WebService::Soundcloud',
    license           => 'perl',
    dist_author       => 'Jonathan Stowe <jns+gh@gellyfish.co.uk>',
    dist_version_from => 'lib/WebService/Soundcloud.pm',
    build_requires    => {
        'Test::More'     => 0,
        'LWP::UserAgent' => '6.03',
        'LWP::Protocol::https'   => '6.02',
        'URI'            => 0,
        'JSON'           => 0,
        'HTTP::Headers'  => 0
    },
    requires           => { 'perl' => 5.006, },
    add_to_cleanup     => ['WebService-Soundcloud-*'],
    create_makefile_pl => 'traditional',
);
$builder->create_build_script();
