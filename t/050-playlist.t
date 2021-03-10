#!/usr/bin/env raku

use v6.c;

use Test;

use WebService::Soundcloud;

my $me-data = $*PROGRAM.parent.child("data/playlist.json").slurp;

my $me;

lives-ok { $me = WebService::Soundcloud::Playlist.from-json($me-data) }, "new Playlist object from JSON";
isa-ok $me, WebService::Soundcloud::Playlist;



done-testing;
# vim: expandtab shiftwidth=4 ft=raku
