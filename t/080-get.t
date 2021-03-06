#!raku

use v6;
use Test;

use URI;

use WebService::Soundcloud;
# Create a constuctor

my $scloud = WebService::Soundcloud.new(
    client-id       => 'a1afc8eb1cbb96b787a5fb5232a8b4f6',
    client-secret   => 'd78d89f377b28d9f2a2692a14a55c501',
    redirect-uri    => 'http://localhost/callback',
    debug           => True
);

isa-ok( $scloud, WebService::Soundcloud );

# coverage for response-format and request-format subroutines
my $res_format = 'json';
my $req_format = 'json';
# default should be set to 'json', get response-format test
ok( $scloud.response-format.defined, "response-format is defined." );
is($scloud.response-format, 'json', 'and has the correct default');
# default should be set to 'json', get request-format test
ok( defined( $scloud.request-format() ), "request-format is defined." );
is($scloud.request-format(), 'json', 'and has the correct default');
# set response-format test

lives-ok { $scloud.response-format = $res_format }, 'Accept header element set/get works through response-format!';
is($scloud.response-format, $res_format, "and we got that value");
# set request-format test

lives-ok { $scloud.request-format = $req_format }, 'Content-Type header element set/get works through request-format!' ;
is($scloud.request-format, $req_format, "and it is right");
# test get_authorization_url
my $url = URI.new(uri => 'https://api.soundcloud.com/connect?response_type=code&scope=non-expiring&client_id=a1afc8eb1cbb96b787a5fb5232a8b4f6&redirect_uri=http%3A%2F%2Flocalhost%2Fcallback&client_secret=d78d89f377b28d9f2a2692a14a55c501');

my $redirect_url = $scloud.get-authorization-url(scope => 'non-expiring');

for $url.query.keys -> $k {
    is $redirect_url.query{$k}, $url.query{$k}, "Got correct $k in authorization-url";
}

my $token;


# this access_token we got is non-expiring one. So we can use this for testing.
my $access_token = '1-165377-189454708-b3a63c8b3fda4';
#my $access_token = $token<access_token>;

$scloud.auth-details<access_token> = $access_token;

ok(my $me = $scloud.get('/me'),'get to me');
ok($me.is-success(),"and request worked");

ok($me = $scloud.get-object('/me'), "get object /me");


ok(my $tracks = $scloud.get('/me/tracks'), 'get to /me/tracks');
ok($tracks.is-success(), "and the request succeeded");

ok(my $track-list = $scloud.get-list('/me/tracks'), "get_list on '/me/tracks'");
ok($track-list.elems, "there are tracks - fragile as it could get deleted");
is($track-list.elems, $me<track_count>, "and what we expected");

my %dubious-keys = 'permalink_url'  => "they aren't consistent about the scheme",
                   'waveform_url'   => 'appears they sometime use different hosts',
                   'user'           => 'URIs in user object vary',
                   'playback_count' => "playback_count not consistent";

for $track-list.list -> $track {
    is($track<user><user_id>, $me<user_id>, "got the right user id");

    my $track-one;
    ok(my $id = $track<id>, "and we got a track ID");
    lives-ok { $track-one = $scloud.get-object("/tracks/$id") }, "get-object on track";
    for $track.keys -> $k {
        todo(%dubious-keys{$k}) if %dubious-keys{$k}:exists;
        is-deeply $track-one{$k}, $track{$k}, "got the right $k";
    }
    my $file = $id ~ '.' ~ ( $track{'original-format'} || 'wav');

    skip("downloads not working yet", 2);
    next;
    ok($scloud.download($id, $file), "download");
    ok($file.IO.s, "and the file got downloaded");
    unlink $file;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=raku
