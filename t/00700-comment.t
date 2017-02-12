#!/usr/bin/env perl6

use v6.c;

use Test;

use WebService::Soundcloud;

my $comment-data = $*PROGRAM.parent.child("data/comment.json").slurp;

my $comment;

lives-ok { $comment = WebService::Soundcloud::Comment.from-json($comment-data) }, "new Comment object from JSON";
isa-ok $comment, WebService::Soundcloud::Comment;



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
