#!/usr/bin/env perl6

use v6.c;

use Test;

use WebService::Soundcloud;

my $me-data = $*PROGRAM.parent.child("data/track.json").slurp;

my $me;

lives-ok { $me = WebService::Soundcloud::Track.from-json($me-data) }, "new Track object from JSON";
isa-ok $me, WebService::Soundcloud::Track;



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
