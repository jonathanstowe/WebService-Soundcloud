#!/usr/bin/env perl6

use v6.c;

use Test;

use WebService::Soundcloud;

my $me-data = $*PROGRAM.parent.child("data/user.json").slurp;

my $me;

lives-ok { $me = WebService::Soundcloud::User.from-json($me-data) }, "new User object from JSON";
isa-ok $me, WebService::Soundcloud::User;



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
