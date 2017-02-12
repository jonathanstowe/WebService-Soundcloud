#!/usr/bin/env perl6

use v6.c;

use Test;

use WebService::Soundcloud;

my $me-data = $*PROGRAM.parent.child("data/me.json").slurp;

my $me;

lives-ok { $me = WebService::Soundcloud::Me.from-json($me-data) }, "new Me object from JSON";
isa-ok $me, WebService::Soundcloud::Me;
isa-ok $me, WebService::Soundcloud::User;



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
