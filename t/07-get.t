#!perl6

use v6;
use Test;
use lib 'lib';

use WebService::Soundcloud;
# Create a constuctor

my $scloud = WebService::Soundcloud.new(
    client-id       => 'I2OBiw2wX09A9EAU5Qx4w',
    client-secret   => 'twr9Wj7Qw16qrChi2lpl4dxTEWix9JuSg8mOgdF52F8',
    redirect-uri    => 'http://localhost/callback',
    debug           => False
);

isa-ok( $scloud, WebService::Soundcloud );

# coverage for response-format and request-format subroutines
my $res_format = 'xml';
my $req_format = 'xml';
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
my $url = 'https://api.soundcloud.com/connect?response_type=code&redirect_uri=http%3A%2F%2Flocalhost%2Fcallback&client_id=I2OBiw2wX09A9EAU5Qx4w&client_secret=twr9Wj7Qw16qrChi2lpl4dxTEWix9JuSg8mOgdF52F8&scope=non-expiring';
my $redirect_url = $scloud.get-authorization-url(scope => 'non-expiring');
ok($url eq $redirect_url, 'Get Authrorization URL is success!');
# this access_token we got is non-expiring one. So we can use this for testing.
my $access_token = '6c56e362267b3c0613c1daf784de98c7';
$scloud.{'access_token'} = $access_token;

ok(my $me = $scloud.get('/me'),'get to me');
ok($me.is-success(),"and request worked");

ok(my $tracks = $scloud.get('/me/tracks'), 'get to /me/tracks');
ok($tracks.is-success(), "and the request succeeded");

ok(my @tracks = $scloud.get_list('/me/tracks'), "get_list on '/me/tracks'");
ok(@tracks.elems, "there are tracks - fragile as it could get deleted");
for @tracks -> $track {
    ok(my $id = $track.{'id'}, "and we got a track ID");
    my $file = $id ~ '.' ~ ( $track.{'original-format'} || 'wav');
    
    todo(2, "downloads not working yet");
    ok($scloud.download($id, $file), "download");
    ok($file.IO.s, "and the file got downloaded");
    unlink $file;
}

done;
# vim: expandtab shiftwidth=4 ft=perl6
