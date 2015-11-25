#!perl6

use v6;

use lib 'lib';
use Test;

use-ok('WebService::Soundcloud', 'can load WebService::Soundcloud');
use-ok('WebService::Soundcloud::User', 'can load WebService::Soundcloud::User');


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
