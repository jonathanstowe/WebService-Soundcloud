#!/usr/bin/env raku

use v6.c;

use Test;

use WebService::Soundcloud;

my $connections-data = $*PROGRAM.parent.child("data/connections.json").slurp;

my $connections;

lives-ok { $connections = WebService::Soundcloud::Connections.from-json($connections-data) }, "new Connections object from JSON";

for $connections.list -> $c {
    isa-ok $c, WebService::Soundcloud::Connection;
}



done-testing;
# vim: expandtab shiftwidth=4 ft=raku
